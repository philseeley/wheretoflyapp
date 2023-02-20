import 'package:flutter/material.dart';
import 'data.dart';

class GroupPage extends StatefulWidget {
  final Settings settings;
  final List<Site> sites;
  final Group group;
  final bool isNew;

  GroupPage(this.settings, this.sites, this.group, this.isNew);

  @override
  _GroupState createState() => _GroupState();
}

class _GroupState extends State<GroupPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  bool _sortByLocation = true;

  @override
  Widget build(BuildContext context) {
    List<Site> sites = widget.sites;
    Group group = widget.group;

    if(!widget.isNew)
      _nameCtrl.text = group.name;

    List<Widget> siteWidgetList = <Widget>[];

    Site.sort(sites, _sortByLocation);

    for(Site site in sites) {
      siteWidgetList.add(
          ListTile(
            title: Text(site.title),
            trailing: Checkbox(
              value: group.sites.contains(site.name),
              onChanged: (bool? value) {
                setState(() {
                  if (value!) {
                    group.sites.add(site.name);
                  } else {
                    group.sites.remove(site.name);
                  }
                });
              },
            ),
          ));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Group"),
          actions: <Widget>[
            IconButton(icon: Icon(_sortByLocation ? Icons.gps_fixed : Icons.gps_off),
              onPressed: () {
                setState(() {
                  Site.sort(sites, _sortByLocation);
                  _sortByLocation = !_sortByLocation;
                });
              }),
          ],
        ),
        body: Column(children: <Widget>[
          ListTile(
            title: TextField(
              autofocus: widget.isNew,
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: "Name"),
              onChanged: (name){
                group.name = name;
              }
            )
          ),
          Expanded(child: ListView(children: siteWidgetList))
        ])
    );
  }
}
