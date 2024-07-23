import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/device_info_service.dart';
import '../utils/background_task.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with WidgetsBindingObserver {
  String _responseData = 'No data yet';
  String _deviceId = 'Unknown';
  late LocationTracker _locationTracker;

  @override
  void initState() {
    super.initState();
    _locationTracker = LocationTracker();
    _checkPermissions();
    _getDeviceId();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _locationTracker.startForegroundTracking();
    } else if (state == AppLifecycleState.paused) {
      _locationTracker.stopForegroundTracking();
    }
  }

  Future<void> _getDeviceId() async {
    _deviceId = await DeviceInfoService.getDeviceId();
    setState(() {});
  }

  Future<void> _checkPermissions() async {
    bool hasPermissions = await LocationService.checkAndRequestPermissions();
    if (hasPermissions) {
      _locationTracker.startTracking(context);
      setState(() {
        _responseData = 'Tracking started';
      });
    } else {
      setState(() {
        _responseData = 'Location permission denied';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Tracking'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Tracking every 5 minutes when app is open'),
              const Text('Tracking every 15 minutes when app is minimized'),
              const SizedBox(height: 20),
              Text('Device ID: $_deviceId'),
              const SizedBox(height: 20),
              Text(_responseData),
            ],
          ),
        ),
      ),
    );
  }
}