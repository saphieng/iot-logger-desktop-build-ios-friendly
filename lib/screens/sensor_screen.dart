import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iot_logger/cubits/sensor_cubit.dart/sensor_cubit.dart';
import 'package:iot_logger/cubits/sensor_reading_cubit/sensor_reading_cubit.dart';
import 'package:flutter/services.dart';
import '../shared/layout.dart';
import '../shared/main_card.dart';

class SensorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PortraitLock(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    double cardWidth = MediaQuery.of(context).size.width * (isLandscape ? 0.6 : 0.5);
    double cardHeight = MediaQuery.of(context).size.height * (isLandscape ? 0.23 : 0.2);
    double iconSize = MediaQuery.of(context).size.height * (isLandscape ? 0.185 : 0.1);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Layout(
        content: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // Screen Title (i.e Turbidity)
          children: <Widget>[
            BlocBuilder<SensorCubit, SensorState>(
              builder: (_, state) {
                return Text(
                  "${state.sensorID}",
                  style: Theme.of(context).textTheme.headline1,
                );
              },
            ),
            // Menu
            Container(
              // color: Colors.blue[50],
              //height: cardHeight * (isLandscape ? 0.01 : 0.01),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Download Log Button
                  Container(
                    height: cardHeight,
                    width: cardWidth,
                    child: MainCard(
                      content: InkWell(
                        onTap: () => {
                          Navigator.of(context).pushNamed('/logs'),
                        },
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.folder,
                                color: Theme.of(context).accentColor,
                                size: iconSize,
                              ),
                              Container(
                                child: cardText(context, 'Download Logs', isLandscape),
                                alignment: Alignment.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   width: 10.0,
                  // ),
                  Container(
                    height: cardHeight,
                    width: cardWidth,
                    child: MainCard(
                      content: InkWell(
                        onTap: () => {
                          context.read<SensorReadingCubit>().getCurrentMeasurements(),
                          Navigator.of(context).pushNamed('/readings'),
                        },
                        child: Center(
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  height: iconSize,
                                  width: iconSize,
                                  child: SvgPicture.asset('assets/svgs/real-time.svg'),
                                ),
                                Container(
                                  child: cardText(context, 'Real-time data', isLandscape),
                                  alignment: Alignment.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: cardHeight,
                    width: cardWidth,
                    child: MainCard(
                      content: InkWell(
                        onTap: () => Navigator.of(context).pushNamed('/settings'),
                        child: Center(
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  Icons.settings,
                                  color: Theme.of(context).accentColor,
                                  size: iconSize,
                                ),
                                Container(
                                  child: cardText(context, 'Settings', isLandscape),
                                  alignment: Alignment.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Text cardText(BuildContext context, String text, bool isLandscape) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headline3.copyWith(fontSize: (MediaQuery.of(context).size.width * (isLandscape ? 0.02 : 0.055))),
    );
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
