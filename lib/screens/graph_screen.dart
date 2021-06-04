import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iot_logger/cubits/files_cubit/files_cubit.dart';
import 'package:iot_logger/cubits/sensor_reading_cubit/sensor_reading_cubit.dart';
import '../widgets/graph_card_from_file.dart';

class GraphScreen extends StatelessWidget {
  final String wifiName;
  GraphScreen(this.wifiName);

  @override
  Widget build(BuildContext context) {
    Map arguments = ModalRoute.of(context).settings.arguments;
    String fileName = arguments['fileName'];

    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          child: Image.asset(
            'assets/images/land.jpg',
            fit: BoxFit.fill,
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(0, 0, 0, 0.5),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.center,
            ),
          ),
        ),
        // Back Button
        Padding(
          padding: EdgeInsets.fromLTRB(10, 30, 0, 0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              type: MaterialType.transparency,
              child: BackButton(
                onPressed: () => {
                  if (ModalRoute.of(context).settings.name == "/readings")
                    {BlocProvider.of<SensorReadingCubit>(context).closeTimer()},
                  Navigator.pop(context),
                },
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Delete Button
        Padding(
          padding: EdgeInsets.fromLTRB(0, 42, 20, 0),
          child: Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: 30,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => showDeleteDialog(context, "$fileName"),
                  barrierDismissible: true,
                );
              },
            ),
          ),
        ),
        Container(
          child: Column(
            children: [
              getSaphiLogo(context),
              Container(
                height: MediaQuery.of(context).size.height * 0.85,
                child: pageContent(context, fileName),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget pageContent(BuildContext context, String fileName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // File Name Card (White)
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.1,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              fileName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ),
        // Graph Card and Legend
        Container(
          // color: Colors.blue[50],
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: GraphCardFromFile("${wifiName}_$fileName"),
        ),
      ],
    );
  }

  Widget getSaphiLogo(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // color: Colors.red[40],s
          alignment: Alignment.center,
          height:
              MediaQuery.of(context).size.height * (isLandscape ? 0.1 : 0.15),
          child: SvgPicture.asset(
            'assets/svgs/saphi-logo-white-text.svg',
            width:
                MediaQuery.of(context).size.height * (isLandscape ? 0.3 : 0.15),
          ),
        ),
      ],
    );
  }

  Widget showDeleteDialog(BuildContext context, String fileName) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.30,
        width: MediaQuery.of(context).size.height * 0.90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Text(
                "Are you sure you want to delete $fileName ?",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.05,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(
                    child: Text("No"),
                    onPressed: () => {
                      Navigator.pop(context),
                    },
                  ),
                  VerticalDivider(
                    thickness: 1,
                  ),
                  FlatButton(
                    child: Text("Yes"),
                    onPressed: () => {
                      BlocProvider.of<FilesCubit>(context).deleteFile(fileName),
                      Navigator.popUntil(context, ModalRoute.withName('/logs')),
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
