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
    try {
      int bytesReceived = 0;
      final startTime = DateTime.now();
      
      // Receive number of files
      final numFilesData = await _readBytes(client, 4);
      final numFiles = _decodeInt32(numFilesData);
      
      debugPrint('Receiving $numFiles file(s)');
      
      // Receive each file
      for (int i = 0; i < numFiles; i++) {
        if (_isCancelled) {
          throw Exception('Transfer cancelled');
        }
        
        await _receiveFile(client, i + 1, numFiles, bytesReceived, startTime);
      }
      
      await client.close();
      onComplete?.call();
      
      debugPrint('All files received successfully');
    } catch (e) {
      debugPrint('Error receiving files: $e');
      onError?.call('Receive failed: $e');
      await client.close();
    }
  }
  
  /// Receive a single file
  Future<void> _receiveFile(
    Socket client,
    int fileIndex,
    int totalFiles,
    int previousBytes,
    DateTime startTime,
  ) async {
    // Receive file name length
    final fileNameLengthData = await _readBytes(client, 4);
    final fileNameLength = _decodeInt32(fileNameLengthData);
    
    // Receive file name
    final fileNameData = await _readBytes(client, fileNameLength);
    final fileName = String.fromCharCodes(fileNameData);
    
    // Receive file size
    final fileSizeData = await _readBytes(client, 8);
    final fileSize = _decodeInt64(fileSizeData);
    
    debugPrint('Receiving file $fileIndex/$totalFiles: $fileName ($fileSize bytes)');
    
    // Get downloads directory
    final directory = await _getDownloadsDirectory();
    final filePath = path.join(directory.path, fileName);
    final file = File(filePath);
    
    // Receive file data
    final sink = file.openWrite();
    int fileBytesReceived = 0;
    
    while (fileBytesReceived < fileSize) {
      if (_isCancelled) {
        await sink.close();
        throw Exception('Transfer cancelled');
      }
      
      final remaining = fileSize - fileBytesReceived;
      final toRead = remaining < chunkSize ? remaining : chunkSize;
      
      final chunk = await _readBytes(client, toRead);
      sink.add(chunk);
      fileBytesReceived += chunk.length;
      
      // Calculate progress
      final totalReceived = previousBytes + fileBytesReceived;
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final speed = elapsed > 0 ? (totalReceived / elapsed) * 1000 : 0.0;
      
      // For simplicity, we don't know total size ahead, so progress is per-file
      final progress = fileBytesReceived / fileSize;
      onProgress?.call(progress, speed.toDouble());
    }
    
    await sink.flush();
    await sink.close();
    
    debugPrint('File received: $filePath');
    
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
  
  /// Read exact number of bytes from socket
  Future<Uint8List> _readBytes(Socket socket, int count) async {
    final buffer = BytesBuilder();
    
    await for (var data in socket) {
      buffer.add(data);
      
      if (buffer.length >= count) {
        final bytes = buffer.takeBytes();
        return Uint8List.fromList(bytes.sublist(0, count));
      }
    }
    
    throw Exception('Connection closed before receiving all data');
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
