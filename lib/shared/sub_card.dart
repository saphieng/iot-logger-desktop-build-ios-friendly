import 'package:flutter/material.dart';

class SubCard extends StatelessWidget {
  final Widget content;
  const SubCard({this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        child: content,
      ),
    );
  }
}
