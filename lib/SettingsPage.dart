import 'package:flutter/material.dart';
import 'package:share/share.dart';
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
      SwitchListTile(title: Text("Hide Early/Late Values"),
        value: settings.hideExtremes,
        onChanged: (bool value) {
          setState(() {
            settings.hideExtremes = value;
          });
        }),
      SwitchListTile(title: Text("Show Distance"),
        value: settings.showDistance,
        onChanged: (bool value) {
          setState(() {
            settings.showDistance = value;
          });
        }),
      SwitchListTile(title: Text("Single Page View"),
        value: settings.singlePageView,
        onChanged: (bool value) {
          setState(() {
            settings.singlePageView = value;
          });
        }),
      SwitchListTile(title: Text('Only Show "On" Sites at Start'),
        value: settings.onlyShowOnDefault,
        onChanged: (bool value) {
          setState(() {
            settings.onlyShowOnDefault = value;
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
        leading: Text('Groups:'),
        trailing: Text('Default'),
        title: IconButton(icon: Icon(Icons.add), onPressed: () {
          Group g = Group('new');
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
            if(group == settings.showGroup)
              settings.showGroup = Settings.allGroup;

            settings.groups.remove(group);
          },
          direction: DismissDirection.horizontal,
          child: ListTile(title: Text(group.name),
                          trailing: IconButton(icon: Icon(group.init?Icons.radio_button_checked:Icons.radio_button_unchecked), onPressed: (){
                            setState(() {
                              bool init = !group.init;
                              for (Group g in settings.groups)
                                g.init = false;
                              group.init = init;
                            });
                          }),
                          onTap: () {
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
          IconButton(icon: Icon(Icons.share), onPressed: () {
            Share.share("Android: https://play.google.com/store/apps/details?id=name.seeley.phil.wheretoflyapp\niPhone: https://itunes.apple.com/au/app/where-to-fly/id1439721253");
          }),
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
