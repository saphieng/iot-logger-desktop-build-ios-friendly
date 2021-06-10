import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iot_logger/cubits/sensor_cubit.dart/sensor_cubit.dart';
import '../shared/main_card.dart';

class SensorItem extends StatelessWidget {
  const SensorItem();

  SvgPicture getStatusImage(BuildContext context, bool connectionStatus) {
    switch (connectionStatus) {
      case true:
        return SvgPicture.asset('assets/svgs/connected-plug.svg',
            color: Theme.of(context).accentColor);
        break;
      case false:
        return SvgPicture.asset('assets/svgs/plug.svg',
            color: Theme.of(context).accentColor);
        break;
      default:
        return SvgPicture.asset('assets/svgs/plug.svg',
            color: Theme.of(context).accentColor);
        break;
    }
  }



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorCubit, SensorState>(builder: (_, state) {
      if (state is Connected) {
        return MainCard(
          content: InkWell(
            splashColor: ModalRoute.of(context).settings.name == "/"
                ? Colors.grey
                : Colors.white,
            onTap: () => {
              if (ModalRoute.of(context).settings.name == "/")
                {
                  Navigator.of(context).pushNamed('/sensor'),
                }
            },
            borderRadius: BorderRadius.circular(4),
            child: sensorContent(
                context, getStatusImage(context, true), true, state.sensorID),
          ),
        );
      } else {
        return MainCard(
            content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: sensorContent(
              context, getStatusImage(context, false), false, state.sensorID),
        ));
      }
    });
  }

  Widget sensorContent(BuildContext context, SvgPicture svgImage,
      bool isConnected, String sensorID) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Center(
      child: ListTile(
        leading: isConnected
            ? Icon(
                Icons.circle,
                size: 30,
                color: Colors.green,
              )
            : Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  )
                ],
              ),
        title: Text(
          "$sensorID",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline3.copyWith(
                fontSize: MediaQuery.of(context).size.width * (isLandscape ? 0.03 : 0.06),
              ),
        ),
        trailing: svgImage,
      ),
    );
  }
}
