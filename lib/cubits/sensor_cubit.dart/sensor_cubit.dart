import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iot_logger/models/HeartBeatMessage.dart';
import 'package:iot_logger/services/arduino_repository.dart';

part 'sensor_state.dart';

class SensorCubit extends Cubit<SensorState> {
  final ArduinoRepository _arduinoRepository;

  SensorCubit(this._arduinoRepository) : super(Disconnected("Sensor"));

  void connect() {
    _arduinoRepository.isConnectedStream.listen((HeartBeatMessage message) {
      if (message.isConnected == true) {
        emit(Connected(sensorMap[message.sensorID]));
      } else {
        emit(Disconnected(sensorMap[message.sensorID]));
      }
    });
  }

  void refresh() {
    print("Closing Connections");
    _arduinoRepository.closeConnections();
  }
}
