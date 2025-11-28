import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../domain/entities/file_entity.dart';
import '../domain/entities/device_entity.dart';

/// Service for handling TCP file transfers
class FileTransferService {
  static const int chunkSize = 64 * 1024; // 64KB chunks
  static const int transferPort = 37822;
  
  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  
  // Buffer for reading socket data
  final List<int> _receiveBuffer = [];
  
  // Callbacks for progress tracking
  Function(double progress, double speed)? onProgress;
  Function(String error)? onError;
  Function()? onComplete;
  Function(FileEntity file)? onFileReceived;
  
  bool _isTransferring = false;
  bool _isCancelled = false;
  
  /// Start TCP server to receive files
  Future<void> startServer() async {
    try {
      _serverSocket = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        transferPort,
      );
      
      debugPrint('Server started on port $transferPort');
      
      _serverSocket!.listen((Socket client) {
        debugPrint('Client connected: ${client.remoteAddress.address}');
        _handleIncomingConnection(client);
      });
    } catch (e) {
      debugPrint('Error starting server: $e');
      onError?.call('Failed to start server: $e');
      rethrow;
    }
  }
  
  /// Stop TCP server
  Future<void> stopServer() async {
    await _serverSocket?.close();
    _serverSocket = null;
    debugPrint('Server stopped');
  }
  
  /// Send files to a device
  Future<void> sendFiles({
    required DeviceEntity device,
    required List<FileEntity> files,
  }) async {
    if (_isTransferring) {
      throw Exception('Transfer already in progress');
    }
    
    _isTransferring = true;
    _isCancelled = false;
    
    try {
      debugPrint('=== STARTING FILE TRANSFER ===');
      debugPrint('Target device: ${device.name}');
      debugPrint('Target IP: ${device.ip}:${device.port}');
      debugPrint('Files to send: ${files.length}');
      
      // Connect to receiver
      debugPrint('Attempting to connect...');
      _clientSocket = await Socket.connect(
        device.ip,
        device.port,
        timeout: const Duration(seconds: 10),
      );
      
      debugPrint('✓ Connected to ${device.name} at ${device.ip}:${device.port}');
      
      int totalBytes = 0;
      for (var file in files) {
        totalBytes += file.size;
      }
      
      int sentBytes = 0;
      final startTime = DateTime.now();
      
      // Send number of files first
      _clientSocket!.add(_encodeInt32(files.length));
      await _clientSocket!.flush();
      
      // Send each file
      for (var file in files) {
        if (_isCancelled) {
          throw Exception('Transfer cancelled');
        }
        
        await _sendFile(file, totalBytes, sentBytes, startTime);
        sentBytes += file.size;
      }
      
      await _clientSocket!.flush();
      await _clientSocket!.close();
      
      _isTransferring = false;
      onComplete?.call();
      
      debugPrint('Transfer complete: $sentBytes bytes sent');
    } catch (e) {
      _isTransferring = false;
      debugPrint('Error sending files: $e');
      onError?.call('Transfer failed: $e');
      await _clientSocket?.close();
      rethrow;
    }
  }
  
  /// Send a single file
  Future<void> _sendFile(
    FileEntity fileEntity,
    int totalBytes,
    int sentBytes,
    DateTime startTime,
  ) async {
    final file = File(fileEntity.path);
    
    if (!await file.exists()) {
      throw Exception('File not found: ${fileEntity.path}');
    }
    
    // Send file metadata
    final fileName = path.basename(fileEntity.path);
    final fileNameBytes = Uint8List.fromList(fileName.codeUnits);
    
    _clientSocket!.add(_encodeInt32(fileNameBytes.length));
    _clientSocket!.add(fileNameBytes);
    _clientSocket!.add(_encodeInt64(fileEntity.size));
    await _clientSocket!.flush();
    
    debugPrint('Sending file: $fileName (${fileEntity.sizeFormatted})');
    
    // Send file data in chunks
    final fileStream = file.openRead();
    int fileBytesSent = 0;
    
    await for (var chunk in fileStream) {
      if (_isCancelled) {
        throw Exception('Transfer cancelled');
      }
      
      _clientSocket!.add(chunk);
      fileBytesSent += chunk.length;
      
      // Calculate progress
      final currentSent = sentBytes + fileBytesSent;
      final progress = currentSent / totalBytes;
      
      // Calculate speed (bytes per second)
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final speed = elapsed > 0 ? (currentSent / elapsed) * 1000 : 0.0;
      
      onProgress?.call(progress, speed.toDouble());
      
      // Add small delay to prevent flooding
      if (fileBytesSent % (chunkSize * 10) == 0) {
        await _clientSocket!.flush();
      }
    }
    
    await _clientSocket!.flush();
    debugPrint('File sent: $fileName');
  }
  
  /// Handle incoming connection and receive files
  Future<void> _handleIncomingConnection(Socket client) async {
    _receiveBuffer.clear();
    final completer = Completer<void>();
    
    client.listen(
      (data) async {
        _receiveBuffer.addAll(data);
        debugPrint('Received ${data.length} bytes, buffer now ${_receiveBuffer.length} bytes');
      },
      onDone: () async {
        try {
          debugPrint('Connection closed, processing ${_receiveBuffer.length} bytes');
          await _processReceivedData();
          onComplete?.call();
          debugPrint('All files received successfully');
        } catch (e) {
          debugPrint('Error processing files: $e');
          onError?.call('Receive failed: $e');
        }
        completer.complete();
      },
      onError: (e) {
        debugPrint('Socket error: $e');
        onError?.call('Socket error: $e');
        completer.complete();
      },
    );
    
    await completer.future;
  }
  
  /// Process all received data from buffer
  Future<void> _processReceivedData() async {
    if (_receiveBuffer.length < 4) {
      throw Exception('Not enough data received');
    }
    
    int offset = 0;
    
    // Read number of files
    final numFiles = _decodeInt32(Uint8List.fromList(_receiveBuffer.sublist(offset, offset + 4)));
    offset += 4;
    debugPrint('Processing $numFiles file(s)');
    
    final startTime = DateTime.now();
    int totalReceived = 0;
    
    for (int i = 0; i < numFiles; i++) {
      if (_isCancelled) {
        throw Exception('Transfer cancelled');
      }
      
      // Read file name length
      final fileNameLength = _decodeInt32(Uint8List.fromList(_receiveBuffer.sublist(offset, offset + 4)));
      offset += 4;
      
      // Read file name
      final fileName = String.fromCharCodes(_receiveBuffer.sublist(offset, offset + fileNameLength));
      offset += fileNameLength;
      
      // Read file size
      final fileSize = _decodeInt64(Uint8List.fromList(_receiveBuffer.sublist(offset, offset + 8)));
      offset += 8;
      
      debugPrint('File ${i + 1}/$numFiles: $fileName ($fileSize bytes)');
      
      // Read file data
      final fileData = _receiveBuffer.sublist(offset, offset + fileSize);
      offset += fileSize;
      totalReceived += fileSize;
      
      // Save file
      final directory = await _getDownloadsDirectory();
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final filePath = path.join(directory.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(fileData);
      
      debugPrint('File saved: $filePath');
      
      // Calculate progress
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final speed = elapsed > 0 ? (totalReceived / elapsed) * 1000 : 0.0;
      onProgress?.call((i + 1) / numFiles, speed.toDouble());
      
      // Create FileEntity and notify
      final extension = path.extension(fileName).replaceAll('.', '');
      final receivedFile = FileEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: fileName,
        path: filePath,
        size: fileSize,
        type: FileType.fromExtension(extension),
      );
      
      onFileReceived?.call(receivedFile);
    }
  }
  
  /// Get downloads directory
  Future<Directory> _getDownloadsDirectory() async {
    // Platform-specific downloads directory
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download/LocalShare');
    } else if (Platform.isIOS) {
      // iOS doesn't have a standard downloads folder
      final appDir = await Directory.systemTemp.createTemp('LocalShare');
      return appDir;
    } else if (Platform.isWindows) {
      final homeDir = Platform.environment['USERPROFILE'];
      return Directory('$homeDir\\Downloads\\LocalShare');
    } else if (Platform.isMacOS || Platform.isLinux) {
      final homeDir = Platform.environment['HOME'];
      return Directory('$homeDir/Downloads/LocalShare');
    }
    
    // Fallback
    return Directory.systemTemp;
  }
  
  /// Encode int32 to bytes (big endian)
  Uint8List _encodeInt32(int value) {
    final bytes = Uint8List(4);
    bytes[0] = (value >> 24) & 0xFF;
    bytes[1] = (value >> 16) & 0xFF;
    bytes[2] = (value >> 8) & 0xFF;
    bytes[3] = value & 0xFF;
    return bytes;
  }
  
  /// Decode int32 from bytes (big endian)
  int _decodeInt32(Uint8List bytes) {
    return (bytes[0] << 24) |
        (bytes[1] << 16) |
        (bytes[2] << 8) |
        bytes[3];
  }
  
  /// Encode int64 to bytes (big endian)
  Uint8List _encodeInt64(int value) {
    final bytes = Uint8List(8);
    bytes[0] = (value >> 56) & 0xFF;
    bytes[1] = (value >> 48) & 0xFF;
    bytes[2] = (value >> 40) & 0xFF;
    bytes[3] = (value >> 32) & 0xFF;
    bytes[4] = (value >> 24) & 0xFF;
    bytes[5] = (value >> 16) & 0xFF;
    bytes[6] = (value >> 8) & 0xFF;
    bytes[7] = value & 0xFF;
    return bytes;
  }
  
  /// Decode int64 from bytes (big endian)
  int _decodeInt64(Uint8List bytes) {
    return (bytes[0] << 56) |
        (bytes[1] << 48) |
        (bytes[2] << 40) |
        (bytes[3] << 32) |
        (bytes[4] << 24) |
        (bytes[5] << 16) |
        (bytes[6] << 8) |
        bytes[7];
  }
  
  /// Cancel ongoing transfer
  void cancelTransfer() {
    _isCancelled = true;
    _clientSocket?.close();
  }
  
  /// Check if transfer is in progress
  bool get isTransferring => _isTransferring;
  
  /// Dispose resources
  Future<void> dispose() async {
    _isCancelled = true;
    await _clientSocket?.close();
    await _serverSocket?.close();
  }
}
