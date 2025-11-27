import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../domain/entities/device_entity.dart';

/// Service for UDP multicast device discovery on local network
class NetworkService {
  static const String multicastAddress = '224.0.0.251';
  static const int discoveryPort = 37821;
  static const int transferPort = 37822;
  
  RawDatagramSocket? _socket;
  Timer? _broadcastTimer;
  final Map<String, DeviceEntity> _discoveredDevices = {};
  final StreamController<List<DeviceEntity>> _devicesController =
      StreamController<List<DeviceEntity>>.broadcast();
  
  Stream<List<DeviceEntity>> get devicesStream => _devicesController.stream;
  
  String? _localIpAddress;
  String? _deviceName;
  
  /// Initialize network service with device name
  Future<void> initialize(String deviceName) async {
    _deviceName = deviceName;
    await _getLocalIpAddress();
  }
  
  /// Get local IP address of the device
  Future<String?> _getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          // Skip loopback
          if (addr.address != '127.0.0.1') {
            _localIpAddress = addr.address;
            return _localIpAddress;
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting local IP: $e');
    }
    return null;
  }
  
  /// Get the local IP address
  String? get localIpAddress => _localIpAddress;
  
  /// Start broadcasting presence and listening for other devices
  Future<void> startDiscovery() async {
    try {
      // Bind to discovery port
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        discoveryPort,
      );
      
      // Join multicast group
      _socket!.joinMulticast(InternetAddress(multicastAddress));
      
      // Enable broadcast
      _socket!.broadcastEnabled = true;
      
      // Listen for incoming discovery messages
      _socket!.listen(_handleIncomingData);
      
      // Start broadcasting our presence every 2 seconds
      _broadcastTimer = Timer.periodic(
        const Duration(seconds: 2),
        (_) => _broadcastPresence(),
      );
      
      // Send initial broadcast
      _broadcastPresence();
      
      debugPrint('Discovery started on ${_localIpAddress ?? "unknown"}:$discoveryPort');
    } catch (e) {
      debugPrint('Error starting discovery: $e');
      rethrow;
    }
  }
  
  /// Stop discovery and broadcasting
  Future<void> stopDiscovery() async {
    _broadcastTimer?.cancel();
    _socket?.close();
    _discoveredDevices.clear();
    _devicesController.add([]);
    debugPrint('Discovery stopped');
  }
  
  /// Broadcast presence to network
  void _broadcastPresence() {
    if (_socket == null || _localIpAddress == null || _deviceName == null) {
      return;
    }
    
    final message = jsonEncode({
      'type': 'discovery',
      'deviceName': _deviceName,
      'ipAddress': _localIpAddress,
      'port': transferPort,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    final data = utf8.encode(message);
    
    // Send to multicast address
    _socket!.send(
      data,
      InternetAddress(multicastAddress),
      discoveryPort,
    );
  }
  
  /// Handle incoming UDP packets
  void _handleIncomingData(RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      final datagram = _socket!.receive();
      if (datagram == null) return;
      
      try {
        final message = utf8.decode(datagram.data);
        final data = jsonDecode(message) as Map<String, dynamic>;
        
        if (data['type'] == 'discovery') {
          final deviceIp = data['ipAddress'] as String;
          
          // Don't add ourselves
          if (deviceIp == _localIpAddress) return;
          
          // Create or update device
          final deviceId = deviceIp;
          final device = DeviceEntity(
            name: data['deviceName'] as String,
            ip: deviceIp,
            port: data['port'] as int,
            isAvailable: true,
          );
          
          _discoveredDevices[deviceId] = device;
          _devicesController.add(_discoveredDevices.values.toList());
          
          debugPrint('Discovered device: ${device.name} at ${device.ip}');
        }
      } catch (e) {
        debugPrint('Error parsing discovery message: $e');
      }
    }
  }
  
  /// Remove stale devices (not seen in last 10 seconds)
  void removeStaleDevices() {
    // In a real implementation, you'd track last seen timestamp
    // For now, keep all devices
    _devicesController.add(_discoveredDevices.values.toList());
  }
  
  /// Dispose resources
  void dispose() {
    stopDiscovery();
    _devicesController.close();
  }
}
