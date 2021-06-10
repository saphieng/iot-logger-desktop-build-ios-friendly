import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_logger/cubits/sensor_cubit.dart/sensor_cubit.dart';
import 'package:iot_logger/cubits/sensor_reading_cubit/sensor_reading_cubit.dart';
import 'package:iot_logger/cubits/settings_cubit/settings_cubit.dart';
import 'package:iot_logger/screens/sensor_screen.dart';
import 'package:iot_logger/screens/settings_screen.dart';
import './screens/home_screen.dart';
import './screens/logs_screen.dart';
import './screens/readings_screen.dart';
import './screens/graph_screen.dart';
import 'cubits/files_cubit/files_cubit.dart';
import 'screens/individual_sensor_screen.dart';
import 'services/arduino_repository.dart';
import 'package:window_size/window_size.dart';

ArduinoRepository arduinoRepo = ArduinoRepository();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(1200, 700));
    setWindowTitle('IoT Desktop Logger');
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SensorCubit(arduinoRepo)..connect()),
        BlocProvider(create: (context) => FilesCubit(arduinoRepo)..getFiles()),
        BlocProvider(create: (context) => SettingsCubit(arduinoRepo)..getAllSettings()),
        BlocProvider(create: (context) => SensorReadingCubit(arduinoRepo)),
      ],
      child: IotLoggerApp(),
    ),
  );
}

class IotLoggerApp extends StatelessWidget {
  final green = const Color.fromRGBO(108, 194, 130, 1);
  final darkGreen = const Color.fromRGBO(36, 136, 104, 1);
  final darkBlue = const Color.fromRGBO(57, 68, 76, 1);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IoT Logger',
      theme: ThemeData(
        primaryColor: green,
        focusColor: darkGreen,
        accentColor: darkBlue,
        backgroundColor: Colors.white,
        buttonColor: green,
        fontFamily: 'Montserrat',
        textTheme: ThemeData.light().textTheme.copyWith(
              headline1: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
              headline2: TextStyle(
                fontStyle: FontStyle.normal,
                fontSize: 12,
                color: Colors.white,
              ),
              headline3: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 25,
                color: darkBlue,
              ),
              headline4: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: darkBlue,
              ),
              headline5: TextStyle(
                color: darkBlue,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
              headline6: TextStyle(
                color: darkGreen,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              bodyText1: TextStyle(
                color: darkGreen,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              bodyText2: TextStyle(
                color: darkBlue,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              // texts within icons
              subtitle1: TextStyle(
                color: darkBlue,
                fontSize: 10,
              ),
              subtitle2: TextStyle(
                color: darkBlue,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
      ),
      routes: {
        '/': (ctx) => HomeScreen(),
        '/sensor': (ctx) => SensorScreen(),
        '/logs': (ctx) => LogsScreen(arduinoRepo),
        '/readings': (ctx) => ReadingsScreen(),
        '/graph-reading': (ctx) => GraphScreen(arduinoRepo.wifiName), // passing wifiName to find the correct graph file
        '/settings': (ctx) => SettingsScreen(),
        '/individual-sensor-screen': (ctx) => IndividualSensorScreen(),
      },
    );
  }
}
