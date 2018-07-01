import 'package:flutter/material.dart';
import 'Data.dart';

class SettingsPage extends StatefulWidget {
  final Settings settings;

  SettingsPage(this.settings);

  @override
  _SettingsState createState() => new _SettingsState();
}

class _SettingsState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    Settings settings = widget.settings;

    return(new Scaffold(
      appBar: new AppBar(
        title: new Text("Settings"),
      ),
      body: new ListView(children: <Widget>[
        new SwitchListTile(title: new Text("Show Paragliding Values"), value: settings.showPGValues, onChanged: (bool value){
          setState(() {
            settings.showPGValues = value;
          });
        },)
      ])
    ));
  }
}
