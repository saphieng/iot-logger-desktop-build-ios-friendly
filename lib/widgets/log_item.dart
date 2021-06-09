import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iot_logger/cubits/log_download_cubit/log_download_cubit.dart';
import 'package:iot_logger/services/arduino_repository.dart';
import 'package:iot_logger/shared/rive_animation.dart';
import 'dart:io';

class LogItem extends StatelessWidget {
  final String fileName;
  final ArduinoRepository arduinoRepository;
  const LogItem(this.fileName, this.arduinoRepository);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LogDownloadCubit(arduinoRepository), // add fileName
      child: _LogItem(fileName: fileName),
    );
  }
}

class _LogItem extends StatelessWidget {
  final String fileName;
  const _LogItem({this.fileName});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogDownloadCubit, LogDownloadState>(builder: (_, state) {
      return Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 10,
        ),
        child: InkWell(
          onTap: () => null,
          borderRadius: BorderRadius.circular(4),
          child: //Center(
            //child:
            logTile(context, state, fileName),
          //),
        ),
      );
    });
  }

  Widget logTile(BuildContext context, LogDownloadState state, String fileName) {

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    var theWidth = MediaQuery.of(context).size.width * (isLandscape ? 0.4 : 0.8);
    if (state is LogLoaded) {
      // When file is loaded but not downloaded (Initial State)
      return GestureDetector(
        onTapDown: (TapDownDetails details) {
          context.read<LogDownloadCubit>().downloadFile(fileName);
        },
        child: Container(
          width: theWidth,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Folder Icon
              Container(
                //alignment: Alignment.center,
                child: Icon(
                  Icons.folder,
                  color: Theme.of(context).accentColor,
                  size: MediaQuery.of(context).size.width * 0.03,
                ),
              ),
              // File Date
              Container(
                child: logDate(context, state, fileName),
              ),
              // Download Icon
              Container(
                width: MediaQuery.of(context).size.width * 0.018,
                child: SvgPicture.asset(
                  'assets/svgs/download.svg',
                ),
              ),
            ],
          ),
        ),
      );
    } else if (state is LogDownloading) {
      // When file is downloading
      return Container(
        child: Stack(
          children: [
            LinearProgressIndicator(
              minHeight: double.infinity,
              value: state.progress,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Download Percentage
                  Container(
                    alignment: Alignment.center,
                    child: folderIcon(context, state),
                  ),
                  // File Date
                  Container(
                    alignment: Alignment.center,
                    child: logDate(context, state, fileName),
                  ),
                  // Loading Animation
                  Container(
                    width: MediaQuery.of(context).size.width * 0.03,
                    height: MediaQuery.of(context).size.height * 0.03,
                    alignment: Alignment.center,
                    child: RiveAnimation(),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    } else {
      //When file is downloaded
      return GestureDetector(
        onTapDown: (TapDownDetails details) {
          Navigator.of(context).pushNamed('/graph-reading', arguments: {'fileName': fileName});
        },
        child: Container(
          // color: Colors.blue,
          child: Container(
            width: theWidth,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Folder Icon
                Container(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.folder,
                    color: Theme.of(context).accentColor,
                    size: MediaQuery.of(context).size.width * 0.03,
                  ),
                ),
                // File Date
                Container(
                  alignment: Alignment.center,
                  child: logDate(context, state, fileName),
                ),
                // Tick Icon
                Container(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.done_outline,
                    size: MediaQuery.of(context).size.width * 0.024,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget folderIcon(BuildContext context, LogDownloadState state) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Text(
          '${(state.progress * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ],
    );
  }

  Widget logDate(
      BuildContext context, LogDownloadState state, String fileName) {
    return Text(
      fileName,
      style: TextStyle(
          color: Theme.of(context).focusColor,
          fontSize: MediaQuery.of(context).size.width * 0.02,
          fontStyle: FontStyle.italic,
          fontFamily: 'Montserrat'),
    );
  }
}
