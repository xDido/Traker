import 'package:battery_plus/battery_plus.dart';

class BatteryService {
  static Future<int> getBatteryLevel() async {
    Battery battery = Battery();
    return await battery.batteryLevel;
  }
}