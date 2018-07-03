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
        }),
        new SwitchListTile(title: new Text("Show Forecast"), value: settings.showForecast, onChanged: (bool value){
          setState(() {
            settings.showForecast = value;
          });
        }),
        new ListTile(
          leading: new Text("Icon Size"),
          title: new Slider(min: 30.0, max: 60.0, divisions: 6, value: settings.iconSize, onChanged: (double value){
            setState(() {
              settings.iconSize = value;
            });
        })
        )
      ])
    ));
  }
}
