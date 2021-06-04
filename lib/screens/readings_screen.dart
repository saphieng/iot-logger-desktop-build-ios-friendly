import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_logger/cubits/sensor_reading_cubit/sensor_reading_cubit.dart';
import '../shared/layout.dart';
import '../widgets/sensor_item.dart';

class ReadingsScreen extends StatelessWidget {
  void refreshPage() {
    print('refreshing readings screen');
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Layout(
      content: isLandscape
          ? SingleChildScrollView(child: pageContent(context, isLandscape))
          : pageContent(context, isLandscape),
    );
  }

  Widget pageContent(BuildContext context, bool isLandscape) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            SensorItem(),
            BlocBuilder<SensorReadingCubit, SensorReadingState>(
              builder: (_, state) {
                if (state is Loaded) {
                  return Container(
                    // color: Colors.blue[50],
                    height: MediaQuery.of(context).size.height * 0.60,
                    width: MediaQuery.of(context).size.width * 0.80,
                    child: GridView(
                      padding: EdgeInsets.only(top: 10),
                      children: state.readings
                          .asMap()
                          .entries
                          .map(
                            (reading) => new Container(
                              // color: Colors.blue,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 20),
                                elevation: 5,
                                child: InkWell(
                                  onTap: () => {
                                    Navigator.of(context).pushNamed(
                                      '/individual-sensor-screen',
                                      arguments: {'index': reading.key},
                                    ),
                                  },
                                  child: Center(
                                    child: ListTile(
                                      leading: Text(
                                          "${state.readings[reading.key][0].sensorName}"),
                                      trailing: Text(
                                          "${state.readings[reading.key][0].sensorReading}"),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      gridDelegate: Platform.isWindows
                          ? SliverGridDelegateWithMaxCrossAxisExtent(
                              childAspectRatio: 4,
                              crossAxisSpacing:
                                  MediaQuery.of(context).size.width * 0.03,
                              mainAxisSpacing:
                                  MediaQuery.of(context).size.height * 0.07,
                              maxCrossAxisExtent:
                                  MediaQuery.of(context).size.width * 0.4,
                            )
                          : SliverGridDelegateWithMaxCrossAxisExtent(
                              childAspectRatio: 5.5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 5,
                              maxCrossAxisExtent:
                                  MediaQuery.of(context).size.width * 1,
                            ),
                    ),
                  );

                  // ListView.builder(
                  //   itemCount: state.readings.length,
                  //   itemBuilder: (context, index) {
                  //     return Container(
                  //       // color: Colors.blue,
                  //       height: MediaQuery.of(context).size.height * 0.18,
                  //       child: Card(
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.all(
                  //             Radius.circular(5),
                  //           ),
                  //         ),
                  //         margin: const EdgeInsets.symmetric(
                  //             horizontal: 40, vertical: 20),
                  //         elevation: 5,
                  //         child: InkWell(
                  //           onTap: () => {
                  //             Navigator.of(context).pushNamed(
                  //               '/individual-sensor-screen',
                  //               arguments: {'index': index},
                  //             ),
                  //           },
                  //           child: Center(
                  //             child: ListTile(
                  //               leading: Text(
                  //                   "${state.readings[index][0].sensorName}"),
                  //               trailing: Text(
                  //                   "${state.readings[index][0].sensorReading}"),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                  // );
                } else
                  //Loading Spinner
                  return Padding(
                    padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
                    child: Container(
                      // color: Colors.blue[50],
                      width: MediaQuery.of(context).size.height * 0.30,
                      height: MediaQuery.of(context).size.height * 0.30,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                    ),
                  );
              },
            )
          ],
        ),
      ],
    );
  }
}
