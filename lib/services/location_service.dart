import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStreamSubscription;

  static Future<bool> checkAndRequestPermissions() async {
    var locationStatus = await Permission.location.request();
    var backgroundStatus = await Permission.locationAlways.request();
    return locationStatus.isGranted && backgroundStatus.isGranted;
  }

  static Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  void startLocationUpdates(void Function(Position) onLocationUpdate) {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // in meters
      ),
    ).listen(onLocationUpdate);
  }

  void stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  void dispose() {
    stopLocationUpdates();
  }
}