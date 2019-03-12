import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'Data.dart';
import 'SiteForecastListView.dart';
import 'SettingsPage.dart';
import 'ReleaseNotesPage.dart';

void main() => runApp(WhereToFlyApp());

class WhereToFlyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextStyle ts = Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 4);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Where To Fly',
      home: Main(),
      theme: ThemeData(textTheme: TextTheme(body1: ts, subhead: ts))
    );
  }
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> with WidgetsBindingObserver {
  Settings settings;
  PackageInfo packageInfo;

  bool locationAvailable = false;
  double latitude = 0.0;
  double longitude = 0.0;
  bool sortByLocation = true;
  bool onlyShowOn = true;

  Sites _sites;
  Data _data;

  _MainState() {
    init();
  }

  init() async {
    settings = await Settings.load();
    packageInfo = await PackageInfo.fromPlatform();
    getForecast();
  }

  getForecast() async {
    try {
      var loc = <String, double>{};

      loc = await Location().getLocation();
      latitude = loc["latitude"];
      longitude = loc["longitude"];
      locationAvailable = true;
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to get location", toastLength: Toast.LENGTH_LONG);
    }

    try {
      dynamic data;

      var uri = Uri.https(
        'wheretofly.info:9443', '/run/current.json');

      http.Response response = await http.get(uri);
      data = json.decode(response.body);

//      String s = '';
//      data = json.decode(s);

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      if (data != null)
        setState(() {
          try {
            _data = Data.fromJson(data);
            _sites = Sites.fromJson(data, latitude, longitude);
          } catch (e, s) {
            print(e);
            print(s);
          }

          _sort();

          String version = packageInfo.version;

          if(settings.version != version) {
            settings.version = version;
            Navigator.push(
              context, MaterialPageRoute(builder: (context) {
              return ReleaseNotesPage("What's New in Version "+version);
            }));
          }

        });
    } catch (e) {
      getForecast();
    }
  }

  _sort(){
    Site.sort(_sites.sites, locationAvailable && sortByLocation);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state)
    {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.suspending:
        if(settings != null)
          settings.save();
        break;
      case AppLifecycleState.resumed:
        break;
    }
  }

  _showSite(Site s) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SiteForecast(settings, _data, _sites.sites, s);
    }));
  }

  Future<void> _refreshForecast() async
  {
    setState(() {
      _sites = null;
    });
    return getForecast();
  }

  @override
  Widget build(BuildContext context) {

    if(_sites == null || _sites.sites.length == 0)
      return Scaffold(
        appBar: AppBar(title: Text("Where To Fly")),
        body: Center(child: Stack(children: <Widget>[Text("Waiting for\nLocation and Data", textAlign: TextAlign.center,), CircularProgressIndicator()],alignment: Alignment.center))
      );

    List<Widget> pages = List<Widget>();

    List<String> dates = settings.showRASP ? _data.raspDates : _data.dates;
    List<String> times = settings.showRASP ? _data.raspTimes : _data.times;

    for(String day in dates)
    {
      List<Widget> list = List<Widget>();

      for (Site s in _sites.sites)
      {
        if(settings.showGroup == Settings.allGroup || settings.showGroup.sites.contains(s.name)) {
          Forecast forecast = s.dates[day];

          Row forecastRow = SiteForecastListView.buildForecastRow(
            context, settings, times, day, forecast, onlyShowOn, false);

          if (forecastRow != null) {
            list.add(InkWell(child: SiteForecastListView.buildTitleRow(context, settings, s), onTap: () {_showSite(s);}));
            list.add(InkWell(child: forecastRow, onTap: () {_showSite(s);}));

            if (settings.showForecast && (forecast.imgTitle.length > 0))
              list.add(Text(
                forecast.imgTitle, textAlign: TextAlign.center, style: Theme
                .of(context)
                .textTheme
                .body2));
          }
        }
      }

      // If we're hiding the extreme values we might not have any rows to show.
      if(list.length > 0) {
        Row timeRow = SiteForecastListView.buildTimeRow(
            context, settings, times, false, day);

        pages.add(Column(children: <Widget>[
              timeRow,
              Expanded(child: RefreshIndicator(onRefresh: _refreshForecast, child: ListView(children: list)))
            ])
        );
      }
    }

    List<Widget> actions = [
      IconButton(icon: Icon(Icons.power_settings_new,
        color: onlyShowOn ? Colors.red : Colors.white),
        onPressed: () {
          setState(() {
            onlyShowOn = !onlyShowOn;
          });
        }),
      IconButton(icon: Icon(
        settings.showForecast ? Icons.cloud : Icons.cloud_off),
        onPressed: () {
          setState(() {
            settings.showForecast = !settings.showForecast;
          });
        }),
      IconButton(icon: Icon(
        settings.showRASP ? Icons.blur_on: Icons.blur_off),
        onPressed: () {
          setState(() {
            settings.showRASP= !settings.showRASP;
          });
        }),
      IconButton(icon: Icon(Icons.settings), onPressed: () {
        Navigator.push(
          context, MaterialPageRoute(builder: (context) {
          return SettingsPage(settings, _sites.sites);
        }));
      })
    ];

    if(locationAvailable)
      actions.insert(0, IconButton(icon: Icon(
        sortByLocation ? Icons.gps_fixed : Icons.gps_off),
        onPressed: () {
          setState(() {
            sortByLocation = !sortByLocation;
            _sort();
          });
        }));

    List<DropdownMenuItem<Group>> groupList = [];
    groupList.add(DropdownMenuItem<Group>(value: Settings.allGroup, child: Text(Settings.allGroup.name)));

    for (Group g in settings.groups)
      groupList.add(DropdownMenuItem<Group>(value: g, child: Text(g.name)));

    return Scaffold(
      appBar: AppBar(
        title: Theme(
          data: ThemeData(
            canvasColor: Colors.blue,
            textTheme: TextTheme(subhead: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 4, color: Colors.white)),
          ),
          child: DropdownButton<Group>(
            onChanged: (Group group) {
              setState(() {
                settings.showGroup = group;
              });
            },
            items: groupList,
            value: settings.showGroup
           )
        ),
        actions: actions
      ),
      body: PageView(children: pages)
    );
  }
}

class SiteForecast extends StatefulWidget {
  final Site site;
  final Data data;
  final Settings settings;
  final List<Site> sites;

  SiteForecast(this.settings, this.data, this.sites, this.site);

  @override
  _SiteForecastState createState() => _SiteForecastState();
}

class _SiteForecastState extends State<SiteForecast> {

  @override
  Widget build(BuildContext context) {
    Settings settings = widget.settings;
    Site site = widget.site;
    Data data = widget.data;
    List<Widget> actions = [];

    List<String> dates = (settings.showRASP) ? data.raspDates : data.dates;
    List<String> times = (settings.showRASP) ? data.raspTimes : data.times;

    actions.add(
      IconButton(icon: Icon(Icons.info), onPressed: (){
        setState(() {
          launch(site.url);
        });
      }));
    actions.add(
      IconButton(icon: Icon(Icons.cloud_upload), onPressed: (){
        setState(() {
          launch(site.weatherURL);
        });
      }));
    if(site.obsURL != null)
      actions.add(
        IconButton(icon: Icon(Icons.cloud, color: Colors.red), onPressed: (){
          setState(() {
            launch(site.obsURL);
          });
        }));
    if(site.url != null)
      actions.add(
        IconButton(icon: Icon(settings.showForecast?Icons.cloud:Icons.cloud_off), onPressed: (){
          setState(() {
            settings.showForecast = !settings.showForecast;
          });
        }));
    actions.add(
      IconButton(icon: Icon(settings.showRASP?Icons.blur_on:Icons.blur_off), onPressed: (){
        setState(() {
          settings.showRASP = !settings.showRASP;
        });
      }));
    actions.add(
      IconButton(icon: Icon(Icons.settings), onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)
        {
          return SettingsPage(settings, widget.sites);
        }));
      }));

    return Scaffold(
      appBar: AppBar(actions: actions),
      body: Column(children: <Widget>[
        SiteForecastListView.buildTitleRow(context, settings, site),
        SiteForecastListView.buildTimeRow(context, settings, times, true, null),
        Expanded(child: SiteForecastListView(settings, dates, times, site))
        ])
    );
  }
}
