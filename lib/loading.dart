import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  String _responseData = 'No data yet';
  Timer? _timer;
  final Battery _battery = Battery();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    // Request location permission
    var status = await Permission.location.request();
    if (status.isGranted) {
      _startTimer();
    } else {
      setState(() {
        _responseData = 'Location permission denied';
      });
    }
  }

  void _startTimer() {
    sendPostRequest();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      sendPostRequest();
    });
  }

  Future<void> sendPostRequest() async {
    setState(() {
      _responseData = 'Sending request...';
    });

    final String url = 'https://script.google.com/macros/s/AKfycbxloBer49j8CFgbd8LvKWZcTR0Tn46D_ta39Nfofr8dWqnT05sBT6uTyG6lu0u44ymjmw/exec';

    // Get current position
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // Get battery level
    int batteryLevel = await _battery.batteryLevel;

    Map<String, dynamic> body = {
      'driverUniqueID': 'your_driver_id', // You might want to use SharedPreferences to store and retrieve this
      'coordinates': '${position.longitude},${position.latitude}',
      'date': DateTime.now().toString().split(' ')[0],
      'time': DateTime.now().toString().split(' ')[1].substring(0, 5),
      'batteryLevel': batteryLevel,
      'mobileStatus': 'on', // You might need to implement a way to check this
      'appStatus': 'installed',
      'dataStatus': 'on', // You might need to implement a way to check this
      'permissionMissing': [] // You might want to check for other permissions here
    };
    print(body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        setState(() {
          _responseData = 'POST request successful\nResponse: ${response.body}';
        });
      } else {
        setState(() {
          _responseData = 'POST request failed\nStatus code: ${response.statusCode}\nResponse: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _responseData = 'Error occurred: $e';
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Tracking'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Auto-sending every 5 minutes'),
            const SizedBox(height: 20),
            Text(_responseData),
          ],
        ),
      ),
    );
  }
}