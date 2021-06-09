part of 'sensor_reading_cubit.dart';

@immutable
abstract class SensorReadingState {
  const SensorReadingState();
}

class Loading extends SensorReadingState {
  const Loading() : super();
}

class Loaded extends SensorReadingState {
  final List<List<SensorReading>> readings;
  const Loaded({
    this.readings,
  }) : super();
}
