import 'package:flutter/material.dart';
import 'Data.dart';

class GroupsPage extends StatefulWidget {
  final Settings settings;
  final List<Site> sites;

  GroupsPage(this.settings, this.sites);

  @override
  _GroupsState createState() => new _GroupsState();
}

class _GroupsState extends State<GroupsPage> {

  @override
  Widget build(BuildContext context) {
    Settings settings = widget.settings;

    List<Widget> groupWidgetList = new List<Widget>();

    for (Group group in settings.groups)
      groupWidgetList.add(
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

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Groups"),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.add),
              onPressed: () {
                Group g = Group();
                g.name = 'new';
                settings.groups.add(g);
                Navigator.push(context, new MaterialPageRoute(builder: (context) {
                  return GroupPage(settings, widget.sites, g, true);
                }));
              }),
        ],
      ),
      body: new ListView(children: groupWidgetList)
    );
  }
}

class GroupPage extends StatefulWidget {
  final Settings settings;
  final List<Site> sites;
  final Group group;
  final bool isNew;

  GroupPage(this.settings, this.sites, this.group, this.isNew);

  @override
  _GroupState createState() => new _GroupState();
}

class _GroupState extends State<GroupPage> {
  final TextEditingController _nameCtrl = new TextEditingController();
  bool _sortByLocation = true;

  @override
  Widget build(BuildContext context) {
    Settings settings = widget.settings;
    List<Site> sites = widget.sites;
    Group group = widget.group;

    _nameCtrl.text = group.name;
    _nameCtrl.selection = TextSelection(baseOffset: 0, extentOffset: 0);

    List<Widget> siteWidgetList = new List<Widget>();

    Site.sort(sites, _sortByLocation);

    for(Site site in sites)
      siteWidgetList.add(
          new ListTile(
            title: new Text(site.title),
            trailing: new Checkbox(
                value: group.sites.contains(site.name),
                onChanged: (bool value) {
                  setState(() {
                    if(value)
                      group.sites.add(site.name);
                    else
                      group.sites.remove(site.name);
                  });
                },
            ),
          ));

    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Edit Group"),
          actions: <Widget>[
            new IconButton(icon: new Icon(_sortByLocation ? Icons.location_on : Icons.location_off),
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
