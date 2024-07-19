import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'loading.dart';

const String taskName = "com.example.repeatingTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Background task started");
    await sendPostRequest();

    // Reschedule the task
    await Workmanager().registerOneOffTask(
      taskName,
      taskName,
      initialDelay: Duration(minutes: 2),
    );

    print("Task rescheduled");
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true
  );
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
      home: const Loading(),
    );
  }
}