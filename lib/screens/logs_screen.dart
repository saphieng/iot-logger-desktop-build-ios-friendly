import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iot_logger/cubits/files_cubit/files_cubit.dart';
import 'package:iot_logger/services/arduino_repository.dart';

import '../shared/layout.dart';
import '../widgets/log_item.dart';
import '../shared/sub_card.dart';
import '../widgets/sensor_item.dart';

class LogsScreen extends StatelessWidget {
  final ArduinoRepository arduinoRepo;
  LogsScreen(this.arduinoRepo);

  refreshPage() {
    print('refreshing logs');
  }

  @override
  Widget build(BuildContext context) {
    print('Width ' + MediaQuery.of(context).size.width.toString());

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Layout(
      content: isLandscape
          ? SingleChildScrollView(child: pageContent(context))
          : pageContent(context),
    );
  }

  Widget pageContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            SensorItem(),
            SubCard(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Past Logs',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      )),
                  const SizedBox(width: 5),
                  SvgPicture.asset('assets/svgs/toggle-arrow.svg'),
                ],
              ),
            ),
            BlocBuilder<FilesCubit, FilesState>(
              builder: (_, state) {
                if (state is LoadingFiles) {
                  //Loading Spinner
                  return Padding(
                    padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: Container(
                      // color: Colors.blue[50],
                      width: MediaQuery.of(context).size.width * 0.20,
                      height: MediaQuery.of(context).size.width * 0.20,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                    ),
                  );
                }
                if (state is Files) {
                  return Container(
                    // color: Colors.red[50],
                    height: MediaQuery.of(context).size.height * 0.53,
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: GridView(
                      padding: EdgeInsets.only(top: 10),
                      children: state.fileNames
                          .map(
                            (fileName) => new LogItem(fileName, arduinoRepo),
                          )
                          .toList(),
                      gridDelegate: Platform.isWindows
                          ? SliverGridDelegateWithMaxCrossAxisExtent(
                              childAspectRatio: 5,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
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
                } else {
                  return CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
