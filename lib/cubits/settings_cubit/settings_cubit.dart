import 'dart:io';

import 'package:bloc/bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iot_logger/services/arduino_repository.dart';
import 'package:package_info/package_info.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  ArduinoRepository _arduinoRepository;
  String ssid = "";
  String password = "";
  String remainingSpace = "";
  String usedSpace = "";
  String batteryVoltage = "";
  String batteryADC = "";
  String loggingPeriod = "";
  String time = "";
  String version = "";
  String buildNumber = "";

  SettingsCubit(this._arduinoRepository) : super(LoadingSettings());

  getAllSettings() async {
    print("getting All settings");
    if (!Platform.isWindows) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    }

    await getBatteryInfo();
    await getSDCardInfo();
    await getLoggingPeriod();
    await getRTCTime();
    await getWifiDetails();

    emit(
      Loaded(
        remainingSpace: this.remainingSpace,
        usedSpace: this.usedSpace,
        batteryADC: this.batteryADC,
        batteryVoltage: this.batteryVoltage,
        loggingPeriod: this.loggingPeriod,
        time: this.time,
        ssid: this.ssid,
        password: this.password,
        version: this.version,
        buildNumber: this.buildNumber,
      ),
    );
  }

  void refresh() {
    print("settings updated");
    emit(
      Loaded(
        remainingSpace: this.remainingSpace,
        usedSpace: this.usedSpace,
        batteryADC: this.batteryADC,
        batteryVoltage: this.batteryVoltage,
        loggingPeriod: this.loggingPeriod,
        time: this.time,
        ssid: this.ssid,
        password: this.password,
        version: this.version,
        buildNumber: this.buildNumber,
      ),
    );
  }

  getRTCTime() async {
    print("getting current time");
    _arduinoRepository.getRTCTime();
    time = await _arduinoRepository.settingStreamController.stream.first;
    refresh();
  }

  getLoggingPeriod() async {
    print("getting logging period");
    _arduinoRepository.getLoggingPeriod();
    loggingPeriod =
        await _arduinoRepository.settingStreamController.stream.first;

    refresh();
  }

  getSDCardInfo() async {
    print("getting SD Card info");
    _arduinoRepository.getSDCardInfo();
    String value =
        await _arduinoRepository.settingStreamController.stream.first;

    List<String> result = value.split(",");
    remainingSpace = result[0];
    usedSpace = result[1];
    refresh();
  }

  getWifiDetails() async {
    print("getting Wifi info");
    _arduinoRepository.getWifiDetails();
    String value =
        await _arduinoRepository.settingStreamController.stream.first;

    List<String> result = value.split(",");
    ssid = result[0];
    password = result[1];
    refresh();
  }

  getBatteryInfo() async {
    print("getting battery info");
    _arduinoRepository.getBatteryInfo();

    String value =
        await _arduinoRepository.settingStreamController.stream.first;

    List<String> batteryInfoString = value.split(",");
    batteryADC = batteryInfoString[0];
    batteryVoltage = batteryInfoString[1];
    refresh();
  }

  setWifiSSD(String name) {
    _arduinoRepository.setWifiSSID(name);
    getWifiDetails();
  }

  setWifiPassword(String password) {
    _arduinoRepository.setWifiPassword(password);
    getWifiDetails();
  }

  setLoggingPeriod(int loggingPeriod) {
    _arduinoRepository.setLoggingPeriod(loggingPeriod);
    getLoggingPeriod();
  }

  setArduinoTime() {
    _arduinoRepository.setRTCTime();
    getRTCTime();
  }
}
