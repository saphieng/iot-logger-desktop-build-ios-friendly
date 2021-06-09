import 'package:flutter/material.dart';

class ReadingItem extends StatelessWidget {
  final String name;
  const ReadingItem(this.name);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 5,
      ),
      width: double.infinity,
      child: Card(
        child: InkWell(
          onTap: () => Navigator.of(context)
              .pushNamed('/graph-reading', arguments: name),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Center(
                child: Text(name, style: Theme.of(context).textTheme.headline6),
              ),
              trailing: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: '5.2',
                      style: Theme.of(context).textTheme.headline5),
                  WidgetSpan(
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ],),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
