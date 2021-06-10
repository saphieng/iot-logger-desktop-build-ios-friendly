import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_logger/cubits/sensor_reading_cubit/sensor_reading_cubit.dart';
import '../shared/layout.dart';
import '../widgets/graph_item_from_list.dart';
import 'package:flutter/services.dart';

class IndividualSensorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PortraitLock(context);

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Layout(
        content: isLandscape
            ? SingleChildScrollView(
                child: pageContent(context),
              )
            : pageContent(context),
      ),
    );
  }

  Widget pageContent(BuildContext context) {
    PortraitLock(context);

    Map arguments = ModalRoute.of(context).settings.arguments;
    int index = arguments['index'];
    return BlocBuilder<SensorReadingCubit, SensorReadingState>(
      builder: (_, state) {
        if (state is Loaded) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            // color: Colors.blue[50],
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sensor Name
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      state.readings[index][0].sensorName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                ),
                // Last Reading Text
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.height * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Last Reading",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline4.copyWith(fontSize: 12),
                        ),
                        Text(
                          state.readings[index][0].sensorReading,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline4.copyWith(fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                ),
                // Graph
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(18),
                    ),
                    color: Theme.of(context).accentColor,
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.4,
                  // margin: EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  child: GraphItemFromList(state.readings[index]),
                ),
              ],
            ),
          );
        } else {
          //Loading Spinner
          return Padding(
            padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
            child: Container(
              // color: Colors.blue[50],
              width: MediaQuery.of(context).size.width * 0.40,
              height: MediaQuery.of(context).size.width * 0.40,
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.blue,
                ),
              ),
            ),
          );
        }
      },
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
