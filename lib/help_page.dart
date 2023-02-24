import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common.dart';
import 'data.dart';
import 'release_notes_page.dart';

class HelpPage extends StatelessWidget {
  final ScrollController _controller = ScrollController();
  final Settings settings;

  HelpPage(this.settings, {super.key});

  _showChangelog (BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const ReleaseNotesPage("Change Log");
    }));
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> iconsTooLight = <Widget>[];
    List<Widget> iconsOn = <Widget>[];
    List<Widget> iconsTooStrong = <Widget>[];

    if(settings.enhanceOnSites){
      iconsTooLight.add(Icon(outlineIconMap[Colors.yellow], size: 35.0));
      iconsOn.add(Icon(outlineIconMap[Colors.lightGreen], size: 35.0));
      iconsTooStrong.add(Icon(outlineIconMap[Colors.orange], size: 35.0));
    }
    iconsTooLight.add(const Icon(Icons.forward, color: Colors.yellow, size: 35.0));
    iconsOn.add(const Icon(Icons.forward, color: Colors.lightGreen, size: 35.0));
    iconsTooStrong.add(const Icon(Icons.forward, color: Colors.orange, size: 35.0));

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
            Row(children: <Widget>[
              Expanded(child: Stack(alignment: AlignmentDirectional.center, children: iconsTooLight)),
              Expanded(child: Stack(alignment: AlignmentDirectional.center, children: iconsOn)),
              Expanded(child: Stack(alignment: AlignmentDirectional.center, children: iconsTooStrong)),
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
                      ..onTap = () { openUrl('http://ausrasp.com'); }),
                  const TextSpan(text: ' Thermal Updraft Velocity. '),
                  TextSpan(text: 'Donate',
                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () { openUrl('https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=DA88MPHUFMKS4&currency_code=AUD'); }),
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

  static String mailURL = "mailto:feedback@$wtfSite?subject=WTF%20Feedback";
  static String supportURL = "$wtfURL/wtf-info.html";

  _support() async {
    try {
      await openUrl(mailURL);
    } on PlatformException catch (_){
      openUrl(supportURL);
    }
  }
}
