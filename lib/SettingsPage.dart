import 'package:flutter/material.dart';
import 'Data.dart';
import 'GroupPage.dart';

class SettingsPage extends StatefulWidget {
  final Settings settings;
  final List<Site> sites;

  SettingsPage(this.settings, this.sites);

  @override
  _SettingsState createState() => new _SettingsState();
}

class _SettingsState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    Settings settings = widget.settings;

    List<Widget> list = [
      SwitchListTile(title: new Text("Show Paragliding Values"),
        value: settings.showPGValues,
        onChanged: (bool value) {
          setState(() {
            settings.showPGValues = value;
          });
        }),
      new SwitchListTile(title: new Text("Show Forecast"),
        value: settings.showForecast,
        onChanged: (bool value) {
          setState(() {
            settings.showForecast = value;
          });
        }),
      new SwitchListTile(title: new Text("Hide Early/Late Values"),
        value: settings.hideExtremes,
        onChanged: (bool value) {
          setState(() {
            settings.hideExtremes = value;
          });
        }),
      new ListTile(
        leading: new Text("Icon Size"),
        title: new Slider(min: 30.0,
          max: 60.0,
          divisions: 6,
          value: settings.iconSize,
          onChanged: (double value) {
            setState(() {
              settings.iconSize = value;
            });
          }),
      ),
      new ListTile(
        title: Text('Groups:'),
        trailing: IconButton(icon: Icon(Icons.add), onPressed: () {
          Group g = Group();
          g.name = 'new';
          settings.groups.add(g);
          Navigator.push(context, new MaterialPageRoute(builder: (context) {
            return GroupPage(settings, widget.sites, g, true);
          }));
        }),
      )
    ];

    for (Group group in settings.groups)
      list.add(
        new Dismissible(
          key: new GlobalKey(),
          secondaryBackground: new ListTile(trailing: new Icon(Icons.delete)),
          background: new ListTile(leading: new Icon(Icons.delete)),
          onDismissed: (direction) {
            settings.groups.remove(group);
          },
          direction: DismissDirection.horizontal,
          child: new ListTile(title: new Text(group.name), onTap: () {
            Navigator.push(
              context, new MaterialPageRoute(builder: (context) {
              return new GroupPage(settings, widget.sites, group, false);
            })
            );
          }
          )
        )
      );

    return(new Scaffold(
      appBar: new AppBar(
        title: new Text("Settings"),
      ),
      body: new ListView(children: list)
    ));
  }
}
