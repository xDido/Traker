import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/device_info_service.dart';
import '../utils/background_task.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _responseData = 'No data yet';
  String _deviceId = 'Unknown';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _getDeviceId();
  }

  Future<void> _getDeviceId() async {
    _deviceId = await DeviceInfoService.getDeviceId();
    setState(() {});
  }

  Future<void> _checkPermissions() async {
    bool hasPermissions = await LocationService.checkAndRequestPermissions();
    if (hasPermissions) {
      startBackgroundTask();
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
              const Text('Tracking every 1 minutes'),
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