import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
part 'graph_state.dart';

class GraphCubit extends Cubit<GraphState> {
  GraphCubit() : super(Loading());
  List<FlSpot> temp = [];
  List<FlSpot> nepheloNTU = [];
  List<FlSpot> nepheloFNU = [];
  List<FlSpot> tu = [];

  double tempMax = -1000;
  double tempMin = 1000;
  double nepheloNTUMax = -1000;
  double nepheloNTUMin = 1000;
  double nepheloFNUMax = -1000;
  double nepheloFNUMin = 1000;
  double tuMax = -1000;
  double tuMin = 1000;

  loadGraph(String fileName) async {
    var directory = Platform.isWindows
        ? await getDownloadsDirectory()
        : await getApplicationDocumentsDirectory();

    await File('${directory.path}/$fileName').readAsLines().then(
      (List<String> lines) {
        // Find Min and Max values for each type
        for (int i = 1; i < lines.length; i++) {
          if (!(lines[i].contains("Timestamp"))) {
            List<String> readingsList = lines[i].split(",");
            if (readingsList.length == 6) {
              // Check temp
              if (double.parse(readingsList[2]) > tempMax) {
                tempMax = double.parse(readingsList[2]);
              }
              if (double.parse(readingsList[2]) < tempMin) {
                tempMin = double.parse(readingsList[2]);
              }

              // Check nepheloNTU
              if (double.parse(readingsList[3]) > nepheloNTUMax) {
                nepheloNTUMax = double.parse(readingsList[3]);
              }
              if (double.parse(readingsList[3]) < nepheloNTUMin) {
                nepheloNTUMin = double.parse(readingsList[3]);
              }

              // Check nepheloFNU
              if (double.parse(readingsList[4]) > nepheloFNUMax) {
                nepheloFNUMax = double.parse(readingsList[4]);
              }
              if (double.parse(readingsList[4]) < nepheloFNUMin) {
                nepheloFNUMin = double.parse(readingsList[4]);
              }

              // Check tu
              if (double.parse(readingsList[5]) > tuMax) {
                tuMax = double.parse(readingsList[5]);
              }
              if (double.parse(readingsList[5]) < tuMin) {
                tuMin = double.parse(readingsList[5]);
              }
            }
          }
        }

        // Add each line to graph dataset as normalised value
        for (int i = 1; i < lines.length; i++) {
          if (!(lines[i].contains("Timestamp"))) {
            List<String> readingsList = lines[i].split(",");

            temp.add(
              FlSpot(
                double.parse(
                  readingsList[0].substring(11, 13) +
                      "." +
                      readingsList[0].substring(14, 16),
                ),
                normaliseValue(double.parse(readingsList[2]), tempMin, tempMax),
              ),
            );

            nepheloNTU.add(
              FlSpot(
                double.parse(readingsList[0].substring(11, 13) +
                    "." +
                    readingsList[0].substring(14, 16)),
                normaliseValue(double.parse(readingsList[3]), nepheloNTUMin,
                    nepheloNTUMax),
              ),
            );

            nepheloFNU.add(
              FlSpot(
                double.parse(readingsList[0].substring(11, 13) +
                    "." +
                    readingsList[0].substring(14, 16)),
                normaliseValue(double.parse(readingsList[4]), nepheloFNUMin,
                    nepheloFNUMax),
              ),
            );

            tu.add(
              FlSpot(
                double.parse(readingsList[0].substring(11, 13) +
                    "." +
                    readingsList[0].substring(14, 16)),
                normaliseValue(double.parse(readingsList[5]), tuMin, tuMax),
              ),
            );
          }
        }
      },
    );

    emit(Loaded(
      readings: [temp, nepheloNTU, nepheloFNU, tu],
      tempMax: tempMax,
      tempMin: tempMin,
      nepheloNTUMax: nepheloNTUMax,
      nepheloNTUMin: nepheloNTUMin,
      nepheloFNUMax: nepheloFNUMax,
      nepheloFNUMin: nepheloFNUMin,
      tuMax: tuMax,
      tuMin: tuMin,
    ));
  }

  double normaliseValue(double value, double min, double max) {
    double result = ((value - min) / (max - min));
    return result;
  }
}
