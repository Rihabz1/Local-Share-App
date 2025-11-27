import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../domain/entities/device_entity.dart';
import '../services/network_service.dart';

class DeviceDiscoveryProvider with ChangeNotifier {
  final List<DeviceEntity> _nearbyDevices = [];
  bool _isScanning = false;
  Timer? _scanTimer;
  StreamSubscription<List<DeviceEntity>>? _devicesSubscription;
  
  final NetworkService _networkService = NetworkService();

  List<DeviceEntity> get nearbyDevices => _nearbyDevices;
  bool get isScanning => _isScanning;

  Future<void> startScanning() async {
    if (_isScanning) return;
    
    _isScanning = true;
    _nearbyDevices.clear();
    notifyListeners();

    try {
      // Get device name
      final deviceName = Platform.isWindows 
          ? Platform.environment['COMPUTERNAME'] ?? 'Windows PC'
          : Platform.isAndroid 
              ? 'Android Device' 
              : Platform.isIOS 
                  ? 'iOS Device'
                  : Platform.isMacOS
                      ? 'Mac'
                      : 'Unknown Device';
      
      // Initialize network service
      await _networkService.initialize(deviceName);
      
      // Listen to discovered devices
      _devicesSubscription = _networkService.devicesStream.listen((devices) {
        _nearbyDevices.clear();
        _nearbyDevices.addAll(devices);
        notifyListeners();
      });
      
      // Start UDP discovery
      await _networkService.startDiscovery();
      
      debugPrint('Started scanning for devices...');
    } catch (e) {
      debugPrint('Error starting scan: $e');
      _isScanning = false;
      notifyListeners();
    }
  }

  void stopScanning() {
    _devicesSubscription?.cancel();
    _networkService.stopDiscovery();
    _scanTimer?.cancel();
    _isScanning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopScanning();
    _networkService.dispose();
    super.dispose();
  }
}
