import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/entities/device_entity.dart';
import '../services/network_service.dart';
import '../core/utils/device_info_helper.dart';

class DeviceDiscoveryProvider with ChangeNotifier {
  final List<DeviceEntity> _nearbyDevices = [];
  bool _isScanning = false;
  Timer? _scanTimer;
  StreamSubscription<List<DeviceEntity>>? _devicesSubscription;
  
  final NetworkService _networkService = NetworkService();

  List<DeviceEntity> get nearbyDevices => _nearbyDevices;
  bool get isScanning => _isScanning;

  Future<void> startScanning() async {
    if (_isScanning) {
      debugPrint('Already scanning, ignoring...');
      return;
    }
    
    debugPrint('=== STARTING DEVICE SCAN ===');
    _isScanning = true;
    _nearbyDevices.clear();
    notifyListeners();

    try {
      // Get device name
      final deviceName = await DeviceInfoHelper.getDeviceName();
      
      debugPrint('Device name: $deviceName');
      
      // Initialize network service
      debugPrint('Initializing network service...');
      await _networkService.initialize(deviceName);
      debugPrint('Local IP: ${_networkService.localIpAddress}');
      
      // Listen to discovered devices
      _devicesSubscription = _networkService.devicesStream.listen((devices) {
        debugPrint('Devices stream update: ${devices.length} device(s)');
        _nearbyDevices.clear();
        _nearbyDevices.addAll(devices);
        for (var device in devices) {
          debugPrint('  - ${device.name} @ ${device.ip}:${device.port}');
        }
        notifyListeners();
      });
      
      // Start UDP discovery
      debugPrint('Starting UDP discovery...');
      await _networkService.startDiscovery();
      
      debugPrint('\u2713 Started scanning for devices');
    } catch (e) {
      debugPrint('\u274c Error starting scan: $e');
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
