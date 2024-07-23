import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  static Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } catch (e) {
      print('Error getting device info: $e');
    }
    return 'Unknown';
  }
}