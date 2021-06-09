import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class RiveAnimation extends StatefulWidget {
  @override
  _RiveAnimationState createState() => _RiveAnimationState();
}

class _RiveAnimationState extends State<RiveAnimation> {
  final riveFileName = 'assets/animations/rotating-arrows.riv';
  Artboard _artboard;

  @override
  void initState() {
    _loadRiveFile();
    super.initState();
  }

  // loads a Rive file
  void _loadRiveFile() async {
    final bytes = await rootBundle.load(riveFileName);
    final file = await RiveFile.import(bytes);

    // if (RiveFile.import(bytes) != null) {
    // Select an animation by its name
    setState(
      () => _artboard = file.mainArtboard
        ..addController(
          SimpleAnimation('rotate'),
        ),
    );
    //}
  }

  /// Show the rive file, when loaded
  @override
  Widget build(BuildContext context) {
    return _artboard != null ? Rive(artboard: _artboard, fit: BoxFit.cover) : Container();
  }
}
