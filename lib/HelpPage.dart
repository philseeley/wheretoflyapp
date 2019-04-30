import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Common.dart';
import 'ReleaseNotesPage.dart';

class HelpPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return(Scaffold(
      appBar: AppBar(
        title: Text("Help"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.change_history), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ReleaseNotesPage("Change Log");
            }));
          })
        ],
      ),
      body: ListView(children: <Widget>[
        ListTile(
          leading: Icon(Icons.gps_fixed),
          title: Text("Sort sites by location"),
        ),
        ListTile(
          leading: Icon(Icons.power_settings_new, color: Colors.red),
          title: Text('Only show sites that are "on"'),
        ),
        ListTile(
          leading: Icon(Icons.trending_flat, color: Colors.red),
          title: Text('Show best direction'),
        ),
        ListTile(
          leading: Icon(Icons.cloud),
          title: Text('Show text forecast'),
        ),
        ListTile(
          leading: Icon(Icons.blur_on),
          title: Text('Show RASP Thermal Updraft Velocity'),
        ),
        ListTile(
          leading: Icon(Icons.cloud, color: Colors.red),
          title: Text('Open realtime weather information'),
        ),
        ListTile(
          leading: Icon(Icons.cloud_upload),
          title: Text('Open external weather forecast'),
        ),
        ListTile(
          leading: Icon(Icons.info),
          title: Text('Open external site information'),
        ),
        ListTile(
          leading: Icon(Icons.change_history), title: Text("Show change log")
        ),
        ListTile(
          title: Text('Note: your location and other settings are only used and stored within the app and never sent to any external server.')
        ),
        ListTile(
          leading: Icon(Icons.email), title: Text("Tap here to send feedback and site updates"), onTap: (){
          launch("mailto:feedback@$wtfSite?subject=WTF Feedback");
        }),
      ])
    ));
  }
}
