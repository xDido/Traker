import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';
import 'utils/background_task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeBackgroundTasks();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracker App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoadingScreen(),
    );
  }
}