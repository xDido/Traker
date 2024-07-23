class DeviceData {
  final String driverUniqueID;
  final String coordinates;
  final String date;
  final String time;
  final int batteryLevel;
  final String appStatus;
  final String dataStatus;
  final List<String> permissionMissing;

  DeviceData({
    required this.driverUniqueID,
    required this.coordinates,
    required this.date,
    required this.time,
    required this.batteryLevel,
    this.appStatus = 'background',
    this.dataStatus = 'on',
    this.permissionMissing = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'driverUniqueID': driverUniqueID,
      'coordinates': coordinates,
      'date': date,
      'time': time,
      'batteryLevel': batteryLevel,
      'appStatus': appStatus,
      'dataStatus': dataStatus,
      'permissionMissing': permissionMissing,
    };
  }
}