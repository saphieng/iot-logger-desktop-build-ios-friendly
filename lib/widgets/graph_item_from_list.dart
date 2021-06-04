import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:iot_logger/models/SensorReading.dart';

class GraphItemFromList extends StatelessWidget {
  final List<SensorReading> data;
  GraphItemFromList(this.data);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.35,
            child: LineChart(
              mainData(context, data),
            ),
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.all(20),
          child: Text(
            '${data[0].sensorName}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  LineChartData mainData(
      BuildContext context, List<SensorReading> listOfReadings) {
    return LineChartData(
      backgroundColor: Theme.of(context).accentColor,
      // betweenBarsData: Colors.blue[50],
      gridData: FlGridData(
        show: true,
        horizontalInterval: 22,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0x44EBEDF4),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) =>
              const TextStyle(color: Color(0xffffffff), fontSize: 10),
          getTitles: (value) {
            if (((value % 6 == 0) && value <= 60) || value == 0) {
              return value.toInt().toString();
            } else {
              return '';
            }
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
          show: false,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 60,
      minY: 0,
      maxY: 100,
      lineBarsData: linesBarData(listOfReadings),
    );
  }

  List<LineChartBarData> linesBarData(List<SensorReading> listOfReadings) {
    List<FlSpot> tempSpots = [];
    for (int i = 0; i < listOfReadings.length; i++) {
      tempSpots.add(
        FlSpot(
          i.toDouble(),
          double.parse(listOfReadings[i].sensorReading),
        ),
      );
    }

    final LineChartBarData data = LineChartBarData(
      spots: tempSpots,
      isCurved: false,
      colors: [
        const Color(0xff4af699),
      ],
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
    return [
      data,
    ];
  }
}
