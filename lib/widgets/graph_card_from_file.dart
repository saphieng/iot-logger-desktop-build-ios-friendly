import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_logger/cubits/graph_cubit/graph_cubit.dart';

class GraphCardFromFile extends StatelessWidget {
  final String fileName;
  GraphCardFromFile(this.fileName);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GraphCubit, GraphState>(
      // bloc:
      builder: (_, state) {
        GraphCubit()..loadGraph(fileName);
        if (state is Loaded) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Outter Box
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.35,
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.02, 0, 0),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(18),
                  ),
                  color: Theme.of(context).accentColor,
                  // color: Colors.blue,
                ),
                // Inner Box
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: LineChart(
                    mainData(context, state.readings),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(18),
                  ),
                  color: Theme.of(context).accentColor,
                ),
                child: DataTable(
                  columnSpacing: MediaQuery.of(context).size.width * 0.092,
                  headingRowHeight: MediaQuery.of(context).size.height * 0.04,
                  dataRowHeight: MediaQuery.of(context).size.height * 0.05,
                  headingTextStyle: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                  ),
                  columns: [
                    DataColumn(
                        label: Text(
                      "",
                      style: TextStyle(color: Colors.white),
                    )),
                    DataColumn(
                        label: Text(
                      "",
                      style: TextStyle(color: Colors.white),
                    )),
                    DataColumn(label: Text("Min", textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text("Max", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)))
                  ],
                  rows: [
                    DataRow(
                      cells: [
                        DataCell(
                          Icon(
                            Icons.circle,
                            color: const Color(0xff4af699),
                          ),
                        ), // Green Circle
                        DataCell(Text(
                          "Temp (C)",
                          style: Theme.of(context).textTheme.headline2,
                        )),
                        DataCell(Text(
                          "${state.tempMin}",
                          style: Theme.of(context).textTheme.headline2,
                        )),
                        DataCell(Text(
                          "${state.tempMax}",
                          style: Theme.of(context).textTheme.headline2,
                        )),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(
                          Icon(
                            Icons.circle,
                            color: Colors.yellow, // Yellow Color
                          ),
                        ), // Green Circle,
                        DataCell(Text(
                          "Nephelo NTU",
                          style: Theme.of(context).textTheme.headline2,
                        )),
                        DataCell(Text(
                          "${state.nepheloNTUMin}",
                          style: Theme.of(context).textTheme.headline2,
                        )),
                        DataCell(Text(
                          "${state.nepheloNTUMax}",
                          style: Theme.of(context).textTheme.headline2,
                        )),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(
                          Icon(
                            Icons.circle,
                            color: const Color(0xffaa4cfc), // Purple line
                          ),
                        ),
                        DataCell(Text(
                          "Nephelo FNU",
                          style: Theme.of(context).textTheme.headline2,
                        )),
                        DataCell(Text(
                          "${state.nepheloFNUMin}",
                          style: Theme.of(context).textTheme.headline2,
                        )),
                        DataCell(
                          Text(
                            "${state.nepheloFNUMax}",
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        ),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(
                          Icon(
                            Icons.circle,
                            color: const Color(0xff27b6fc), // Color blue
                          ),
                        ), // Green Circle,
                        DataCell(Text(
                          "TU mg/L",
                          style: Theme.of(context).textTheme.headline2,
                        )),
                        DataCell(Text(
                          "${state.tuMin}",
                          style: Theme.of(context).textTheme.headline2,
                        )),
                        DataCell(Text(
                          "${state.tuMax}",
                          style: Theme.of(context).textTheme.headline2,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Stack(
            children: <Widget>[
              Center(
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
              ),
            ],
          );
        }
      },
    );
  }

  LineChartData mainData(
    BuildContext context,
    List<List<FlSpot>> readings,
  ) {
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: false,
        //touchTooltipData: LineTouchTooltipData(),
      ),
      backgroundColor: Theme.of(context).accentColor,
      gridData: FlGridData(
        show: true,
        horizontalInterval: 0.2,
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
          getTextStyles: (value) => const TextStyle(color: Color(0xffffffff), fontSize: 10),
          getTitles: (value) {
            if (((value % 3 == 0)) || value == 0) {
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
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      minX: 0,
      maxX: 24.00,
      minY: 0,
      maxY: 1,
      lineBarsData: linesBarData(readings),
    );
  }

  List<LineChartBarData> linesBarData(List<List<FlSpot>> readings) {
    final LineChartBarData tempLine = LineChartBarData(
      spots: readings[0],
      isCurved: false,
      colors: [
        const Color(0xff4af699), // Green Color
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

    final LineChartBarData nepheloNTULine = LineChartBarData(
      spots: readings[1],
      isCurved: false,
      colors: [
        Colors.yellow, // Yellow Color
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

    final LineChartBarData nepheloFNULine = LineChartBarData(
      spots: readings[2],
      isCurved: false,
      colors: [
        const Color(0xffaa4cfc), // Purple line
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

    final LineChartBarData tuLine = LineChartBarData(
      spots: readings[3],
      isCurved: false,
      colors: [
        const Color(0xff27b6fc), // Color blue
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

    return [tempLine, nepheloNTULine, nepheloFNULine, tuLine];
  }
}
