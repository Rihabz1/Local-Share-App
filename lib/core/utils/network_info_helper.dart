import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// Helper class to get network information
class NetworkInfoHelper {
  static final NetworkInfo _networkInfo = NetworkInfo();
  
  /// Get the WiFi SSID (network name)
  static Future<String> getWifiName() async {
    try {
      // On Android, we need location permission to get WiFi SSID
      if (Platform.isAndroid) {
        final status = await Permission.location.status;
        if (!status.isGranted) {
          debugPrint('Location permission not granted, requesting...');
          final result = await Permission.location.request();
          if (!result.isGranted) {
            debugPrint('Location permission denied');
            return 'Permission Required';
          }
        }
      }
      
      final wifiName = await _networkInfo.getWifiName();
      debugPrint('WiFi name received: $wifiName');
      
      // Remove quotes that iOS adds
      if (wifiName != null && wifiName.isNotEmpty && wifiName != '<unknown ssid>') {
        return wifiName.replaceAll('"', '');
      }
      
      // Try getting IP to check if actually connected
      final wifiIP = await _networkInfo.getWifiIP();
      if (wifiIP != null && wifiIP.isNotEmpty) {
        return 'Connected ($wifiIP)';
      }
      
      return 'Not Connected';
    } catch (e) {
      debugPrint('Error getting WiFi name: $e');
      return 'Unknown';
    }
  }
  
  /// Get the WiFi IP address
  static Future<String?> getWifiIP() async {
    try {
      return await _networkInfo.getWifiIP();
    } catch (e) {
      debugPrint('Error getting WiFi IP: $e');
      return null;
    }
  }
  
  /// Check if device is connected to WiFi
  static Future<bool> isConnectedToWifi() async {
    try {
      final wifiName = await _networkInfo.getWifiName();
      return wifiName != null && wifiName.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking WiFi connection: $e');
      return false;
    }
  }
}
