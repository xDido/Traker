import 'package:flutter/material.dart';
import 'loading.dart'; // Import the file where you defined the Loading widget

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Loading(), // Use the Loading widget as the home screen
    );
  }

}