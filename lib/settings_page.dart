import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'data.dart';
import 'group_page.dart';
import 'help_page.dart';

class SettingsPage extends StatefulWidget {
  final Settings settings;
  final List<Site> sites;

  const SettingsPage(this.settings, this.sites, {super.key});

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    Settings settings = widget.settings;

    List<Widget> list = [
      SwitchListTile(title: const Text("Show Paragliding Values"),
        value: settings.showPGValues,
        onChanged: (bool value) {
          setState(() {
            settings.showPGValues = value;
          });
        }),
      SwitchListTile(title: const Text("Show Metric Values"),
        value: settings.showMetric,
        onChanged: (bool value) {
          setState(() {
            settings.showMetric = value;
          });
        }),
      SwitchListTile(title: const Text("Hide Early/Late Values"),
        value: settings.hideExtremes,
        onChanged: (bool value) {
          setState(() {
            settings.hideExtremes = value;
          });
        }),
      SwitchListTile(title: const Text("Show Distance"),
        value: settings.showDistance,
        onChanged: (bool value) {
          setState(() {
            settings.showDistance = value;
          });
        }),
      SwitchListTile(title: const Text("Single Page View"),
        value: settings.singlePageView,
        onChanged: (bool value) {
          setState(() {
            settings.singlePageView = value;
          });
        }),
      ListTile(
        leading: const Text("Rows"),
        title: Slider(min: 1,
          max: 7,
          divisions: 6,
          value: settings.maxRows.toDouble(),
          label: settings.maxRows.toString(),
          onChanged: settings.singlePageView ? (double value) {
            setState(() {
              settings.maxRows = value.toInt();
            });
          } : null),
      ),
      SwitchListTile(title: const Text('Only Show "On" Sites at Start'),
          value: settings.onlyShowOnDefault,
          onChanged: (bool value) {
            setState(() {
              settings.onlyShowOnDefault = value;
            });
          }),
      SwitchListTile(title: const Text('Enhance "On" Sites'),
          value: settings.enhanceOnSites,
          onChanged: (bool value) {
            setState(() {
              settings.enhanceOnSites = value;
            });
          }),
      ListTile(
        leading: const Text("Icon Size"),
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
        leading: const Text('Groups:'),
        trailing: const Text('Default'),
          title: IconButton(icon: const Icon(Icons.add), onPressed: () async {
            Group g = Group('new');
            await Navigator.of(context).push(MaterialPageRoute(builder: (context) => GroupPage(settings, widget.sites, g, true)));
            setState(() {
              settings.groups.add(g);
            });
          })
      )
    ];

    for (Group group in settings.groups) {
      list.add(
        Dismissible(
          key: GlobalKey(),
          secondaryBackground: const ListTile(trailing: Icon(Icons.delete)),
          background: const ListTile(leading: Icon(Icons.delete)),
          onDismissed: (direction) {
            if(group == settings.showGroup) {
              settings.showGroup = Settings.allGroup;
            }

            settings.groups.remove(group);
          },
          direction: DismissDirection.horizontal,
          child: ListTile(title: Text(group.name),
                          trailing: IconButton(icon: Icon(group.init?Icons.radio_button_checked:Icons.radio_button_unchecked), onPressed: (){
                            setState(() {
                              bool init = !group.init;
                              for (Group g in settings.groups) {
                                g.init = false;
                              }
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
    }

    return(Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.share), onPressed: () {
            Share.share("Android: https://play.google.com/store/apps/details?id=name.seeley.phil.wheretoflyapp\niPhone: https://itunes.apple.com/au/app/where-to-fly/id1439721253");
          }),
          IconButton(icon: const Icon(Icons.help), onPressed: () {
            Navigator.push(
              context, MaterialPageRoute(builder: (context) {
              return HelpPage(settings);
            }));
          }),
      ]),
      body: ListView(children: list)
    ));
  }
}
