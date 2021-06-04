import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

const double iconSize = 30;

final BorderRadius cardRadius = BorderRadius.circular(10);

final green = const Color.fromRGBO(108, 194, 130, 1);
final darkGreen = const Color.fromRGBO(36, 136, 104, 1);
final darkBlue = const Color.fromRGBO(57, 68, 76, 1);

Widget setIcon(IconData iconData) {
  return Icon(iconData, color: darkBlue, size: iconSize,);
}

Widget setSvgImage(String path) {
  return SvgPicture.asset(path, color: darkBlue, height: iconSize,);
}