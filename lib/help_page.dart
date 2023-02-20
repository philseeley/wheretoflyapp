import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'common.dart';
import 'release_notes_page.dart';

class HelpPage extends StatelessWidget {
  final ScrollController _controller = ScrollController();

  HelpPage({super.key});

  _showChangelog (BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const ReleaseNotesPage("Change Log");
    }));
  }

  @override
  Widget build(BuildContext context) {

    return(Scaffold(
      appBar: AppBar(
        title: const Text("Help"),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.change_history), onPressed: () {
            _showChangelog(context);
            }
          )
        ],
      ),
      body: Row(children: <Widget>[
        Expanded(child: Scrollbar(thumbVisibility: true, controller: _controller, child:
          ListView(controller: _controller, children: <Widget>[
            Row(children: const <Widget>[
              Expanded(child: Icon(Icons.forward, color: Colors.yellow, size: 35.0)),
              Expanded(child: Icon(Icons.forward, color: Colors.lightGreen, size: 35.0)),
              Expanded(child: Icon(Icons.forward, color: Colors.orange, size: 35.0)),
            ]),
            Row(children: const <Widget>[
              Expanded(child: Text("Too Light", textAlign: TextAlign.center)),
              Expanded(child: Text("Where To Fly!", textAlign: TextAlign.center)),
              Expanded(child: Text("Too Strong", textAlign: TextAlign.center)),
            ]),
            const ListTile(
              leading: Icon(Icons.gps_fixed),
              title: Text("Sort sites by location"),
            ),
            const ListTile(
              leading: Icon(Icons.power_settings_new, color: Colors.red),
              title: Text('Only show sites that are "on"'),
            ),
            const ListTile(
              leading: Icon(Icons.trending_flat, color: Colors.red),
              title: Text('Show best direction'),
            ),
            const ListTile(
              leading: Icon(Icons.cloud),
              title: Text('Show text forecast'),
            ),
            ListTile(
              leading: const Icon(Icons.blur_on),
              title: RichText(text: TextSpan(
                style: Theme.of(context).textTheme.titleMedium!.apply(fontWeightDelta: 4),
                children: [
                  const TextSpan(text: 'Show '),
                  TextSpan(text: 'RASP',
                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () { launchUrl(Uri.parse('http://ausrasp.com')); }),
                  const TextSpan(text: ' Thermal Updraft Velocity. '),
                  TextSpan(text: 'Donate',
                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () { launchUrl(Uri.parse('https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=DA88MPHUFMKS4&currency_code=AUD')); }),
                ]
              ))
            ),
            const ListTile(
              leading: Icon(Icons.cloud, color: Colors.red),
              title: Text('Open realtime weather information'),
            ),
            const ListTile(
              leading: Icon(Icons.cloud_upload),
              title: Text('Open external weather forecast'),
            ),
            const ListTile(
              leading: Icon(Icons.info),
              title: Text('Open external site information'),
            ),
            ListTile(
              leading: const Icon(Icons.change_history),
              title: const Text("Show change log"),
              onTap: () { _showChangelog(context); }
            ),
            const ListTile(
              title: Text('Note: your location and other settings are only used and stored within the app and never sent to any external server.')
            ),
            ListTile(
              leading: const Icon(Icons.email), title: const Text("Send feedback and site updates", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)), onTap: _support),
          ]))),
        const Image(image: AssetImage("assets/rasp-scale.png")),
      ])));
  }

  static Uri mailURL = Uri.parse("xmailto:feedback@$wtfSite?subject=WTF%20Feedback");
  static Uri supportURL = Uri.parse("$wtfURL/wtf-info.html");

  _support() async {
    if(await canLaunchUrl(mailURL)) {
      launchUrl(mailURL);
    } else {
      launchUrl(supportURL);
    }
  }
}
