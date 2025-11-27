import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Helper class to get network information
class NetworkInfoHelper {
  static final NetworkInfo _networkInfo = NetworkInfo();
  
  /// Get the WiFi SSID (network name)
  static Future<String> getWifiName() async {
    try {
      final wifiName = await _networkInfo.getWifiName();
      // Remove quotes that iOS adds
      if (wifiName != null) {
        return wifiName.replaceAll('"', '');
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
