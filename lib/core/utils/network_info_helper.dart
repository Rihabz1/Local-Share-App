import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Helper class to get network information
class NetworkInfoHelper {
  static final NetworkInfo _networkInfo = NetworkInfo();
  
  /// Get the WiFi status
  static Future<String> getWifiName() async {
    try {
      // Try to get WiFi name (may not work on all platforms without permissions)
      final wifiName = await _networkInfo.getWifiName();
      debugPrint('WiFi name received: $wifiName');
      
      // Remove quotes that iOS adds and check for valid SSID
      if (wifiName != null && 
          wifiName.isNotEmpty && 
          wifiName != '<unknown ssid>' &&
          wifiName.toLowerCase() != 'unknown' &&
          !wifiName.startsWith('0x') &&
          !wifiName.contains('unknown')) {
        return wifiName.replaceAll('"', '');
      }
      
      // Check if we have an IP (means we're connected)
      final wifiIP = await _networkInfo.getWifiIP();
      if (wifiIP != null && wifiIP.isNotEmpty) {
        return 'WiFi Connected';
      }
      
      return 'Not Connected';
    } catch (e) {
      debugPrint('Error getting WiFi name: $e');
      // Check IP as fallback
      try {
        final wifiIP = await _networkInfo.getWifiIP();
        if (wifiIP != null && wifiIP.isNotEmpty) {
          return 'WiFi Connected';
        }
      } catch (_) {}
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
