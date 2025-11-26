import 'package:flutter/foundation.dart';

class ReceiveProvider with ChangeNotifier {
  bool _isReceiving = false;
  String _localIp = '192.168.1.101';
  int _port = 54321;

  bool get isReceiving => _isReceiving;
  String get localIp => _localIp;
  int get port => _port;
  String get address => '$_localIp:$_port';

  void toggleReceiving() {
    _isReceiving = !_isReceiving;
    notifyListeners();
    
    if (_isReceiving) {
      _startServer();
    } else {
      _stopServer();
    }
  }

  void _startServer() {
    // Mock server start
    debugPrint('Starting server on $_localIp:$_port');
  }

  void _stopServer() {
    // Mock server stop
    debugPrint('Stopping server');
  }

  void setLocalIp(String ip) {
    _localIp = ip;
    notifyListeners();
  }
}
