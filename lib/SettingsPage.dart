import 'package:flutter/material.dart';
import 'Data.dart';
import 'GroupPage.dart';
import 'HelpPage.dart';

class SettingsPage extends StatefulWidget {
  final Settings settings;
  final List<Site> sites;

  SettingsPage(this.settings, this.sites);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    Settings settings = widget.settings;

    List<Widget> list = [
      SwitchListTile(title: Text("Show Paragliding Values"),
        value: settings.showPGValues,
        onChanged: (bool value) {
          setState(() {
            settings.showPGValues = value;
          });
        }),
      SwitchListTile(title: Text("Show Metric Values"),
        value: settings.showMetric,
        onChanged: (bool value) {
          setState(() {
            settings.showMetric = value;
          });
        }),
      SwitchListTile(title: Text("Show Forecast"),
        value: settings.showForecast,
        onChanged: (bool value) {
          setState(() {
            settings.showForecast = value;
          });
        }),
      SwitchListTile(title: Text("Hide Early/Late Values"),
        value: settings.hideExtremes,
        onChanged: (bool value) {
          setState(() {
            settings.hideExtremes = value;
          });
        }),
      ListTile(
        leading: Text("Icon Size"),
        title: Slider(min: 30.0,
          max: 60.0,
          divisions: 6,
          value: settings.iconSize,
          onChanged: (double value) {
            setState(() {
              settings.iconSize = value;
            });
          }),
      ),
      ListTile(
        title: Text('Groups:'),
        trailing: IconButton(icon: Icon(Icons.add), onPressed: () {
          Group g = Group();
          g.name = 'new';
          settings.groups.add(g);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return GroupPage(settings, widget.sites, g, true);
          }));
        }),
      )
    ];

    for (Group group in settings.groups)
      list.add(
        Dismissible(
          key: GlobalKey(),
          secondaryBackground: ListTile(trailing: Icon(Icons.delete)),
          background: ListTile(leading: Icon(Icons.delete)),
          onDismissed: (direction) {
            settings.groups.remove(group);
          },
          direction: DismissDirection.horizontal,
          child: ListTile(title: Text(group.name), onTap: () {
            Navigator.push(
              context, MaterialPageRoute(builder: (context) {
              return GroupPage(settings, widget.sites, group, false);
            })
            );
          }
          )
        )
      );

    return(Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        actions: <Widget>[
        IconButton(icon: Icon(Icons.help), onPressed: () {
          Navigator.push(
            context, MaterialPageRoute(builder: (context) {
            return HelpPage();
          }));
        }),
      ]),
      body: ListView(children: list)
    ));
  }
}
