import 'package:flutter/foundation.dart';
import '../services/file_transfer_service.dart';
import '../services/network_service.dart';
import '../domain/entities/file_entity.dart';
import '../core/utils/device_info_helper.dart';

class ReceiveProvider with ChangeNotifier {
  bool _isReceiving = false;
  String _localIp = '';
  final int _port = 37822;
  
  final FileTransferService _transferService = FileTransferService();
  final NetworkService _networkService = NetworkService();
  final List<FileEntity> _receivedFiles = [];

  bool get isReceiving => _isReceiving;
  String get localIp => _localIp;
  int get port => _port;
  String get address => '$_localIp:$_port';
  List<FileEntity> get receivedFiles => _receivedFiles;

  Future<void> initialize() async {
    debugPrint('=== INITIALIZING RECEIVE PROVIDER ===');
    
    // Get device name
    final deviceName = await DeviceInfoHelper.getDeviceName();
    debugPrint('Device name: $deviceName');
    
    await _networkService.initialize(deviceName);
    _localIp = _networkService.localIpAddress ?? 'Unknown';
    notifyListeners();
  }

  Future<void> toggleReceiving() async {
    _isReceiving = !_isReceiving;
    notifyListeners();
    
    if (_isReceiving) {
      await _startServer();
    } else {
      await _stopServer();
    }
  }

  Future<void> _startServer() async {
    try {
      debugPrint('=== STARTING RECEIVE MODE ===');
      debugPrint('Local IP: $_localIp');
      debugPrint('Port: $_port');
      
      // Setup callbacks for file transfer service
      _transferService.onFileReceived = (file) {
        _receivedFiles.add(file);
        notifyListeners();
        debugPrint('\u2713 File received: ${file.name}');
      };

      _transferService.onProgress = (progress, speed) {
        // Could update UI with receive progress
        debugPrint('Receive progress: ${(progress * 100).toStringAsFixed(1)}% at ${(speed / (1024 * 1024)).toStringAsFixed(2)} MB/s');
      };

      _transferService.onError = (error) {
        debugPrint('\u274c Receive error: $error');
      };

      _transferService.onComplete = () {
        debugPrint('\u2713 All files received');
      };

      // Start TCP server
      debugPrint('Starting TCP server...');
      await _transferService.startServer();
      debugPrint('\u2713 TCP server started');
      
      // Start broadcasting presence
      debugPrint('Starting network discovery broadcast...');
      await _networkService.startDiscovery();
      debugPrint('\u2713 Broadcasting presence');
      
      debugPrint('\u2713 Server fully started on $_localIp:$_port');
    } catch (e) {
      debugPrint('\u274c Error starting server: $e');
      _isReceiving = false;
      notifyListeners();
    }
  }

  Future<void> _stopServer() async {
    await _transferService.stopServer();
    await _networkService.stopDiscovery();
    debugPrint('Server stopped');
  }

  @override
  void dispose() {
    _stopServer();
    _transferService.dispose();
    _networkService.dispose();
    super.dispose();
  }
}
