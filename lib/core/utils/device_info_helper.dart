import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

/// Helper class to get device information
class DeviceInfoHelper {
  static Future<String> getDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Use model name (e.g., "Redmi Note 12", "Galaxy S21")
        return androidInfo.model ?? 'Android Device';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // Use device name set by user (e.g., "John's iPhone")
        return iosInfo.name ?? 'iOS Device';
      } else if (Platform.isWindows) {
        return Platform.environment['COMPUTERNAME'] ?? 'Windows PC';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return macInfo.computerName ?? 'Mac';
      } else if (Platform.isLinux) {
        return Platform.environment['HOSTNAME'] ?? 'Linux PC';
      }
      
      return 'Unknown Device';
    } catch (e) {
      // Fallback if device_info_plus fails
      if (Platform.isAndroid) return 'Android Device';
      if (Platform.isIOS) return 'iOS Device';
      if (Platform.isWindows) return Platform.environment['COMPUTERNAME'] ?? 'Windows PC';
      if (Platform.isMacOS) return 'Mac';
      if (Platform.isLinux) return Platform.environment['HOSTNAME'] ?? 'Linux PC';
      return 'Unknown Device';
    }
  }
}
