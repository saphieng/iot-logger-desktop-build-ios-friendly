part of 'sensor_cubit.dart';

@immutable
abstract class SensorState {
  final String sensorID = "Sensor";
  const SensorState();
}

class Connected extends SensorState {
  final String sensorID;
  const Connected(this.sensorID) : super();
}

class Disconnected extends SensorState {
  final String sensorID;
  const Disconnected(this.sensorID) : super();
}
