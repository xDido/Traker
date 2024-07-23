import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:workmanager/workmanager.dart';

const String taskName = "com.example.repeatingTask";

Future<void> sendPostRequest() async {
  try {
    final String url = 'https://script.google.com/macros/s/AKfycbxloBer49j8CFgbd8LvKWZcTR0Tn46D_ta39Nfofr8dWqnT05sBT6uTyG6lu0u44ymjmw/exec';

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    Battery battery = Battery();
    int batteryLevel = await battery.batteryLevel;

    String deviceId = await getDeviceId();

    Map<String, dynamic> body = {
      'driverUniqueID': deviceId,
      'Device Model': 'test',
      'coordinates' : '${position.latitude},${position.longitude}',
      'date': DateTime.now().toString().split(' ')[0],
      'time': DateTime.now().toString().split(' ')[1].substring(0, 5),
      'batteryLevel': batteryLevel,
      'appStatus': 'background',
      'dataStatus': 'on',
      'permissionMissing': []
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    print('POST request sent. Status: ${response.statusCode} at time ${DateTime.now().toString().split(' ')[1].substring(0, 5)}');

  } catch (e) {
    print('Error in sendPostRequest: $e');
  }
}

Future<String> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  try {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  } catch (e) {
    print('Error getting device info: $e');
  }
  return 'Unknown';
}

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  String _responseData = 'No data yet';
  String _deviceId = 'Unknown';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _getDeviceId();
  }

  Future<void> _getDeviceId() async {
    _deviceId = await getDeviceId();
    setState(() {});
  }

  Future<void> _checkPermissions() async {
    var locationStatus = await Permission.location.request();
    var backgroundStatus = await Permission.locationAlways.request();
    if (locationStatus.isGranted && backgroundStatus.isGranted) {
      _startBackgroundTask();
    } else {
      setState(() {
        _responseData = 'Location permission denied';
      });
    }
  }

  void _startBackgroundTask() {
    Workmanager().registerOneOffTask(
      taskName,
      taskName,
      initialDelay: Duration(minutes: 1),
    );
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