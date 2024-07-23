import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  static Future<bool> checkAndRequestPermissions() async {
    var locationStatus = await Permission.location.request();
    var backgroundStatus = await Permission.locationAlways.request();
    return locationStatus.isGranted && backgroundStatus.isGranted;
  }
}