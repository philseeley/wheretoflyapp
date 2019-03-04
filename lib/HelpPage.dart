import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return(Scaffold(
      appBar: AppBar(
        title: Text("Help"),
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
          leading: Icon(Icons.cloud),
          title: Text('Show text forecast'),
        ),
        ListTile(
          leading: Icon(Icons.blur_on),
          title: Text('Show RASP forecast'),
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
          title: Text('Note: your location and other settings are only used and stored within the app and never sent to any external server.')
        ),
        ListTile(
          leading: Icon(Icons.email), title: Text("Send feedback and site updates"), onTap: (){
          launch("mailto:feedback@wheretofly.info?subject=WTF Feedback");
        }),
      ])
    ));
  }
}
