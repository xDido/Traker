import 'dart:async';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/device_info_service.dart';
import '../services/battery_service.dart';
import '../services/api_service.dart';
import '../models/device_data.dart';
import 'constants.dart';

class LocationTracker {
  static const String foregroundTaskName = "foregroundLocationTrack";
  static const String backgroundTaskName = "backgroundLocationTrack";
  Timer? _foregroundTimer;
  final LocationService _locationService = LocationService();

  void startTracking(BuildContext context) {
    startForegroundTracking();
    setupBackgroundTracking();
  }

  void startForegroundTracking() {
    _foregroundTimer?.cancel();
    _locationService.startLocationUpdates((position) {
      sendPostRequest(position);
    });
    _foregroundTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      // This timer ensures we send updates every 5 minutes even if location hasn't changed
      LocationService.getCurrentPosition().then(sendPostRequest);
    });
  }

  void stopForegroundTracking() {
    _foregroundTimer?.cancel();
    _foregroundTimer = null;
    _locationService.stopLocationUpdates();
  }

  void setupBackgroundTracking() {
    Workmanager().registerPeriodicTask(
      backgroundTaskName,
      backgroundTaskName,
      frequency: const Duration(minutes: 5),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
      ),
    );
  }

  Future<void> sendPostRequest(Position position) async {
    try {
      final deviceId = await DeviceInfoService.getDeviceId();
      final batteryLevel = await BatteryService.getBatteryLevel();

      final now = DateTime.now();
      final data = DeviceData(
        driverUniqueID: deviceId,
        coordinates: '${position.latitude},${position.longitude}',
        date: now.toString().split(' ')[0],
        time: now.toString().split(' ')[1].substring(0, 5),
        batteryLevel: batteryLevel,
      );

      await ApiService.sendPostRequest(data);
      print("Location update sent at ${now.toString()}");
    } catch (e) {
      print("Error sending location update: $e");
    }
  }

  void dispose() {
    stopForegroundTracking();
    _locationService.dispose();
  }
}

class AppLifecycleObserver with WidgetsBindingObserver {
  final LocationTracker locationTracker;

  AppLifecycleObserver(this.locationTracker);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      locationTracker.startForegroundTracking();
    } else if (state == AppLifecycleState.paused) {
      locationTracker.stopForegroundTracking();
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Background task started");
    final locationTracker = LocationTracker();
    await LocationService.getCurrentPosition().then(locationTracker.sendPostRequest);
    print("Background task completed");
    return Future.value(true);
  });
}

// This function can be called from your main.dart or wherever you initialize your app
Future<void> initializeBackgroundTasks() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
}