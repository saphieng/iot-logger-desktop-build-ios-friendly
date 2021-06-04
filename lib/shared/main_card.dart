import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MainCard extends StatelessWidget {
  final Widget content;
  const MainCard({this.content});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Container(
      width:
          MediaQuery.of(context).size.width * (isLandscape ? 0.12 : 1),
      height: (MediaQuery.of(context).size.height * (isLandscape ? 0.22 : 0.15)),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        margin: isLandscape ? EdgeInsets.symmetric(horizontal: 80.0, vertical: 10.0): EdgeInsets.symmetric(horizontal: 38.0, vertical: 20.0),
        elevation: 5,
        child: Center(child: content),
      ),
    );
  }
}
