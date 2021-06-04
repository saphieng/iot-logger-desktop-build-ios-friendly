import 'package:flutter/material.dart';
import 'package:iot_logger/cubits/sensor_cubit.dart/sensor_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

class RefreshButton extends StatelessWidget {
  const RefreshButton();

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Center(
      child: Container(
        width: (Platform.isIOS ? MediaQuery.of(context).size.width * (isLandscape ? 0.81 : 0.81) : MediaQuery.of(context).size.width * (isLandscape ? 0.79 : 0.79) ),
        height: MediaQuery.of(context).size.height * (isLandscape ? 0.175 : 0.1) ,
        // color: Colors.blue,
        child: ElevatedButton(
          onPressed: () => context.read<SensorCubit>().refresh(),
          style: ElevatedButton.styleFrom(
            elevation: 5,
            primary: Theme.of(context).primaryColor, // background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(25),
              ),
            ),
            padding: isLandscape
                ? const EdgeInsets.symmetric(horizontal: 1)
                : const EdgeInsets.all(1),
          ),
          child: Text(
            'Refresh',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * (isLandscape ? 0.03 : 0.06),
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ),
    );
  }
}
