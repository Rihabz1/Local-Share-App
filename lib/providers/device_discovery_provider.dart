import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/entities/device_entity.dart';

class DeviceDiscoveryProvider with ChangeNotifier {
  List<DeviceEntity> _nearbyDevices = [];
  bool _isScanning = false;
  Timer? _scanTimer;

  List<DeviceEntity> get nearbyDevices => _nearbyDevices;
  bool get isScanning => _isScanning;

  void startScanning() {
    if (_isScanning) return;
    
    _isScanning = true;
    _nearbyDevices.clear();
    notifyListeners();

    // Simulate device discovery with mock devices
    _scanTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (timer.tick >= 6) {
        _isScanning = false;
        timer.cancel();
        notifyListeners();
        return;
      }

      // Add mock devices progressively
      if (timer.tick == 1) {
        _nearbyDevices.add(DeviceEntity(
          name: 'Redmi Note 12',
          ip: '192.168.1.102',
          port: 54321,
        ));
      } else if (timer.tick == 2) {
        _nearbyDevices.add(DeviceEntity(
          name: 'Sarah\'s MacBook Pro',
          ip: '192.168.1.105',
          port: 54321,
        ));
      } else if (timer.tick == 3) {
        _nearbyDevices.add(DeviceEntity(
          name: 'Living Room PC',
          ip: '192.168.1.108',
          port: 54321,
        ));
      } else if (timer.tick == 4) {
        _nearbyDevices.add(DeviceEntity(
          name: 'Galaxy Tab S8',
          ip: '192.168.1.110',
          port: 54321,
        ));
      }
      
      notifyListeners();
    });
  }

  void stopScanning() {
    _scanTimer?.cancel();
    _isScanning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }
}
