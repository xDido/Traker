import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/device_data.dart';

class ApiService {
  static const String _url = 'https://script.google.com/macros/s/AKfycbxloBer49j8CFgbd8LvKWZcTR0Tn46D_ta39Nfofr8dWqnT05sBT6uTyG6lu0u44ymjmw/exec';

  static Future<void> sendPostRequest(DeviceData data) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data.toJson()),
      );

      print('POST request sent. Status: ${response.statusCode} at time ${DateTime.now().toString().split(' ')[1].substring(0, 5)}');
    } catch (e) {
      print('Error in sendPostRequest: $e');
    }
  }
}