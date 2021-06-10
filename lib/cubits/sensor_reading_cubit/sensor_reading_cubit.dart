import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iot_logger/models/SensorReading.dart';
import 'package:iot_logger/services/arduino_repository.dart';

part 'sensor_reading_state.dart';

class SensorReadingCubit extends Cubit<SensorReadingState> {
  ArduinoRepository _arduinoRepository;
  Timer measurementRequestTimer;
  List<List<SensorReading>> readings = [];
  List<SensorReading> temp = [];
  List<SensorReading> nepheloNTU = [];
  List<SensorReading> nepheloFNU = [];
  List<SensorReading> tu = [];
  int counter = 0;

  SensorReadingCubit(this._arduinoRepository) : super(Loading());

  refresh() {
    emit(
      Loaded(
        readings: this.readings,
      ),
    );
  }

  getReadings() async {
    _arduinoRepository.getCurrentMeasurements(2);

    String tempString = await _arduinoRepository
        .currentMeasurementsStreamController.stream.first;

    List<String> readingsList = tempString.split(",");

    this.temp.insert(0, SensorReading(readingsList[0], "Temp C"));
    this.nepheloNTU.insert(0, SensorReading(readingsList[1], "Nephelo NTU"));
    this.nepheloFNU.insert(0, SensorReading(readingsList[2], "Nephelo FNU"));
    this.tu.insert(0, SensorReading(readingsList[3], "TU mg/l"));

    while (this.temp.length > 60) {
      this.temp.removeLast();
      this.nepheloNTU.removeLast();
      this.nepheloFNU.removeLast();
      this.tu.removeLast();
    }

    this.readings = [temp, nepheloNTU, nepheloFNU, tu];
    refresh();
  }

  getCurrentMeasurements() async {
    print("get real-time readings");
    await getReadings();

    measurementRequestTimer =
        new Timer.periodic(Duration(seconds: 1), (Timer t) async {
      // print("Request sent");
      await getReadings();
    });
  }

  closeTimer() {
    counter = 0;
    measurementRequestTimer.cancel();
    emit(Loading());
  }
}
