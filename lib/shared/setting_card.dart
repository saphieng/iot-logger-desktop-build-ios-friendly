import 'package:flutter/material.dart';

import '../shared/styling.dart';

class SettingCard extends StatelessWidget {
  final Widget icon;
  final String text;

  SettingCard({this.icon, this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: ListTile(
            leading: icon,
            title: Text(
              text,
              style:
                  Theme.of(context).textTheme.headline5.copyWith(fontSize: 18),
            ),
            trailing: Icon(
              Icons.arrow_forward,
            ),
          ),
        ),
      ),
    );
  }
}
