import 'dart:async';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
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

  void startTracking(BuildContext context) {
    startForegroundTracking();
    setupBackgroundTracking();
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver(this));
  }

  void startForegroundTracking() {
    _foregroundTimer?.cancel();
    _foregroundTimer = Timer.periodic(Duration(minutes: 5), (_) {
      sendPostRequest();
    });
  }

  void stopForegroundTracking() {
    _foregroundTimer?.cancel();
    _foregroundTimer = null;
  }

  void setupBackgroundTracking() {
    Workmanager().registerPeriodicTask(
      backgroundTaskName,
      backgroundTaskName,
      frequency: Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
      ),
    );
  }
}

class _AppLifecycleObserver with WidgetsBindingObserver {
  final LocationTracker _locationTracker;

  _AppLifecycleObserver(this._locationTracker);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _locationTracker.startForegroundTracking();
    } else if (state == AppLifecycleState.paused) {
      _locationTracker.stopForegroundTracking();
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Background task started at ${DateTime.now()}");
    await sendPostRequest();
    print("Background task completed at ${DateTime.now()}");
    return Future.value(true);
  });
}

Future<void> sendPostRequest() async {
  try {
    final position = await LocationService.getCurrentPosition();
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

// This function can be called from your main.dart or wherever you initialize your app
Future<void> initializeBackgroundTasks() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
}