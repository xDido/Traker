import 'package:workmanager/workmanager.dart';
import '../services/location_service.dart';
import '../services/device_info_service.dart';
import '../services/battery_service.dart';
import '../services/api_service.dart';
import '../models/device_data.dart';
import 'constants.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Background task started");
    await sendPostRequest();
    await rescheduleTask();
    print("Task rescheduled");
    return Future.value(true);
  });
}

Future<void> sendPostRequest() async {
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
}

Future<void> rescheduleTask() async {
  await Workmanager().registerOneOffTask(
    taskName,
    taskName,
    initialDelay: Duration(minutes: 1),
  );
}

void startBackgroundTask() {
  Workmanager().registerPeriodicTask(
    taskName,
    taskName,
    frequency: Duration(minutes: 5), // Adjust as needed
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: false,
    ),
  );
}