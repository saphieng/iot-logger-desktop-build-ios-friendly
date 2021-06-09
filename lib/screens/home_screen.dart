import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../shared/layout.dart';
import '../shared/refresh_button.dart';
import '../widgets/sensor_item.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  initState() {
    super.initState();
    checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    PortraitLock(context);

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Layout(
        content: Container(
          margin: (Platform.isIOS ? EdgeInsets.only(bottom: 5.0) : null),
          height: (Platform.isIOS
              ? MediaQuery.of(context).size.height * (isLandscape ? 0.6 : 0.5) + (isLandscape ? 112 : 290)
              : MediaQuery.of(context).size.height * (isLandscape ? 0.6 : 0.5) + (isLandscape ? 95 : 256)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SensorItem(),
              SizedBox(
                height: (Platform.isIOS ? MediaQuery.of(context).size.height * (isLandscape ? 0.2 : 0.20) : MediaQuery.of(context).size.height * (isLandscape ? 0.2 : 0.30)),
              ),
              RefreshButton(),
              //SizedBox(height: MediaQuery.of(context).size.height * (isLandscape? 0.075: 0.001),),
            ],
          ),
        ),
      ),
    );
  }

  void checkPermissions() async {
    if (!Platform.isWindows) {
      await Permission.locationWhenInUse.request();
      await Permission.storage.request();
    }
  }
}

void PortraitLock(BuildContext context) {
  if ((MediaQuery.of(context).size.height < 600) || (MediaQuery.of(context).size.width < 600)) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
