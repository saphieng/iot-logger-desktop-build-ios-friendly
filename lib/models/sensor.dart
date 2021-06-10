import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum DeviceStatus {
  Connected,
  Disconnected,
}

enum LogStatus {
  Loaded,
  Downloading,
  Downloaded,
}

class Sensor {
  final String id;
  final String name;
  final DeviceStatus status;
  final List<Log> logs;
  final double usedSpace;
  final List<Reading> readings;

  const Sensor(
      {@required this.id,
      @required this.name,
      this.status = DeviceStatus.Disconnected,
      this.logs = const [],
      this.usedSpace = 1,
      this.readings = const []});
}

/// `logState` is set to [LogState.Downloading] if progress bar has values >0 and <1.
/// Once `progress` reaches `1`, [LogState.Downloaded]. Otherwise [LogState.Loaded] once the logs of a sensor has been loaded.
class Log {
  final String logId;
  final DateTime date;
  final double progress;
  final LogStatus logState;
  final List<Reading> readings;

  const Log({
    @required this.logId,
    @required this.date,
    this.progress = 0.0,
    this.logState = LogStatus.Loaded,
    this.readings = const [],
  });
}

class Reading {
  final String name;
  const Reading(this.name);
}
