part of 'settings_cubit.dart';

@immutable
abstract class SettingsState {
  const SettingsState();
}

class LoadingSettings extends SettingsState {
  const LoadingSettings() : super();
}

class Loaded extends SettingsState {
  final String usedSpace;
  final String remainingSpace;
  final String batteryADC;
  final String batteryVoltage;
  final String loggingPeriod;
  final String time;
  final String ssid;
  final String password;
  final String version;
  final String buildNumber;
  const Loaded({
    this.usedSpace,
    this.remainingSpace,
    this.batteryADC,
    this.batteryVoltage,
    this.loggingPeriod,
    this.time,
    this.ssid,
    this.password,
    this.buildNumber,
    this.version,
  }) : super();
}
