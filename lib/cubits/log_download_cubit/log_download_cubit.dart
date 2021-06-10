import 'dart:async';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iot_logger/models/Messages.dart';
import 'package:iot_logger/services/arduino_repository.dart';
import 'package:meta/meta.dart';
import '../../models/sensor.dart';
import 'package:async/async.dart';

part 'log_download_state.dart';

class LogDownloadCubit extends Cubit<LogDownloadState> {
  double currentPercentage = 0;

  ArduinoRepository arduinoRepository;
  RestartableTimer timeoutTimer;
  MessageFile currentfile;

  LogDownloadCubit(this.arduinoRepository)
      : super(
          LogLoaded(
            progress: 0.0,
            status: LogStatus.Loaded, // Initial Non-Downloaded State
            icon: SvgPicture.asset(
              'assets/svgs/download.svg',
            ),
          ),
        );

  Future<MessageFile> getIndexedFile(String fileName) async {
    MessageFile file = MessageFile(0.0, []);
    arduinoRepository.getLogFile(fileName);

    await for (MessageFile tempFile in arduinoRepository.fileStream
        .timeout(Duration(seconds: 2), onTimeout: (stream) {
      print("Message timed out");
      stream.close();
      return file;
    })) {
      file = tempFile;
      if (file.percentage == 1.0) {
        break;
      } else {
        emit(LogDownloading(progress: percentage(file.percentage)));
      }
    }

    return file;
  }

  void downloadFile(String fileName) async {
    int count = 0;
    List<String> newList = [];
    MessageFile file;
    int newListSizeInBytes = 0;
    double newListPercentage = 0;
    bool fileIsComplete = false;
    print("Waiting for log file");

    // Attempt to get file 5 times
    while (count < 5 && fileIsComplete != true) {
      print("Download Attempt: $count");

      // Make download attempt
      MessageFile tempFile = await getIndexedFile(fileName);
      print("List Size: ${tempFile.list.length}");

      // Merge attempt with other attempts
      newList = [...tempFile.list, ...newList].toSet().toList();
      newListSizeInBytes = 0;

      // Calculate the size of merged attempt
      for (int i = 0; i < newList.length; i++) {
        newListSizeInBytes +=
            Uint8List.fromList(newList[i].codeUnits).lengthInBytes;
      }

      // Update current file
      file = MessageFile(newListPercentage, newList);

      // Check for Success
      newListPercentage = newListSizeInBytes / arduinoRepository.fileSize;
      print(
          "Merged List Size: ${newList.length} = ${newListPercentage.toString()}%");

      if (newListSizeInBytes >= arduinoRepository.fileSize) {
        print("temp file merged successfully");
        fileIsComplete = true;
      }

      count++;
    }

    // Print final file
    // for (int i = 0; i < file.list.length; i++) {
    //   print(i.toString() + " " + file.list[i]);
    // }

    // Remove headers (i.e Timestamp, UTC, Temp C...)
    List<String> tempList = file.list.sublist(1);

    // Sort final file
    tempList.sort((a, b) => double.parse(a.substring(20, 30))
        .compareTo(double.parse(b.substring(20, 30))));

    // Add header back
    file.list = file.list.sublist(0, 1) + tempList;

    // Prints finale file
    // for (int i = 0; i < file.list.length; i++) {
    //   print(i.toString() + " " + file.list[i]);
    // }

    print("EMITTING RESULT @ $newListPercentage");
    emit(LogDownloaded());
    arduinoRepository.writeListToFile(file.list);
  }

  void stopDownload() {
    emit(LogDownloaded());
    // arduinoRepository.writeMessageToFile();
  }

  double percentage(double newPercentage) {
    if (newPercentage > currentPercentage) {
      currentPercentage = newPercentage;
    }
    return currentPercentage > 1.00 ? 1.00 : currentPercentage;
  }
}
