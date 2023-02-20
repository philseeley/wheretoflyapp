import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'common.dart';
import 'data.dart';
import 'site_forecast_listview.dart';
import 'settings_page.dart';
import 'release_notes_page.dart';
import 'dynamic_appbar.dart';

void main() => runApp(WhereToFlyApp());

class WhereToFlyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextStyle? ts = Theme.of(context).textTheme.titleMedium!.apply(fontWeightDelta: 4);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Where To Fly',
      home: Main(),
      theme: ThemeData(textTheme: TextTheme(bodyMedium: ts, titleMedium: ts))
    );
  }
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> with WidgetsBindingObserver {
  late Settings settings;
  late PackageInfo packageInfo;

  bool locationAvailable = false;
  double latitude = 0.0;
  double longitude = 0.0;

  Sites? _sites;
  late Data _data;

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
      Location location = Location();
      LocationData loc;

      if(await location.serviceEnabled()) {
        loc = await location.getLocation();
        latitude = loc.latitude ?? 0.0;
        longitude = loc.longitude  ?? 0.0;
        locationAvailable = true;
      }
      else {
        Fluttertoast.showToast(msg: "Location is disabled", toastLength: Toast.LENGTH_LONG);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to get location", toastLength: Toast.LENGTH_LONG);
    }

    try {
      dynamic data;

      var uri = Uri.https(
        wtfSitePort, '/run/current.json');

      http.Response response = await http.get(uri);
      data = json.decode(response.body);

//      String s = '';
//      data = json.decode(s);

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      if (data != null) {
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
              return ReleaseNotesPage("What's New in Version $version");
            }));
          }

        });
      }
    } catch (e) {
      getForecast();
    }
  }

  _sort(){
    Site.sort(_sites!.sites, locationAvailable && settings.sortByLocation);
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
      case AppLifecycleState.detached:
        if(settings != null)
          settings.save();
        break;
      case AppLifecycleState.resumed:
        break;
    }
  }

  _showSite(Site s) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SiteForecast(settings, _data, _sites!.sites, s);
    }));
  }

  Future<void> _refreshForecast() async
  {
    setState(() {
      _sites = null;
    });
    getForecast();
  }

  @override
  Widget build(BuildContext context) {

    if(_sites == null || _sites!.sites.isEmpty)
      return Scaffold(
        appBar: AppBar(title: Text("Where To Fly")),
        body: Center(child: Stack(children: <Widget>[Text("Waiting for\nLocation and Data", textAlign: TextAlign.center,), CircularProgressIndicator()],alignment: Alignment.center))
      );

    List<Widget> pages = <Widget>[];

    List<String> dates = settings.showRASP ? _data.raspDates : _data.dates;
    List<String> times = settings.showRASP ? _data.raspTimes : _data.times;

    if(settings.singlePageView)
      singlePage(context, pages, dates, times);
    else
      multiDay(context, pages, dates, times);

    List<IconButton> actions = [
      IconButton(icon: Icon(Icons.power_settings_new,
        color: settings.onlyShowOn ? Colors.red : Colors.white,
        semanticLabel: "Only On",
      ),
        onPressed: () {
          setState(() {
            settings.onlyShowOn = !settings.onlyShowOn;
          });
        }),
      IconButton(icon: Icon(Icons.trending_flat,
        color: settings.showBestDirection ? Colors.red : Colors.white,
        semanticLabel: "Best Direction",
      ),
        onPressed: () {
          setState(() {
            settings.showBestDirection = !settings.showBestDirection;
          });
        }),
      IconButton(icon: Icon(
        settings.showRASP ? Icons.blur_on: Icons.blur_off,
        semanticLabel: "RASP",
      ),
        onPressed: () {
          setState(() {
            settings.showRASP= !settings.showRASP;
          });
        }),
      IconButton(icon: Icon(
        settings.showForecast ? Icons.cloud : Icons.cloud_off,
        semanticLabel: "Forecast",
      ),
        onPressed: () {
          setState(() {
            settings.showForecast = !settings.showForecast;
          });
        }),
      IconButton(icon: Icon(Icons.settings, semanticLabel: "Settings"), onPressed: () async {
        await Navigator.push(
          context, MaterialPageRoute(builder: (context) {
          return SettingsPage(settings, _sites!.sites);
        }));
        setState(() {});
      })
    ];

    if(locationAvailable)
      actions.insert(0, IconButton(icon: Icon(
        settings.sortByLocation ? Icons.gps_fixed : Icons.gps_off, semanticLabel: "Location",),
        onPressed: () {
          setState(() {
            settings.sortByLocation = !settings.sortByLocation;
            _sort();
          });
        }));

    List<DropdownMenuItem<Group>> groupList = [];
    groupList.add(DropdownMenuItem<Group>(value: Settings.allGroup, child: Text(Settings.allGroup.name)));

    for (Group g in settings.groups)
      groupList.add(DropdownMenuItem<Group>(value: g, child: Text(g.name)));

    return Scaffold(
      appBar: DynamicAppBar(
        key: UniqueKey(),
        context: context,
        title: Theme(
          data: ThemeData(
            canvasColor: Colors.blue,
            textTheme: TextTheme(titleMedium: Theme.of(context).textTheme.titleMedium!.apply(fontWeightDelta: 4, color: Colors.white)),
          ),
          child: DropdownButton<Group>(
            onChanged: (Group? group) {
              setState(() {
                settings.showGroup = group!;
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

  void multiDay(BuildContext context, List<Widget> pages, List<String> dates, List<String> times) {
    for(String day in dates)
    {
      List<Widget> list = <Widget>[];

      for (Site s in _sites!.sites)
      {
        if(settings.showGroup == Settings.allGroup || settings.showGroup.sites.contains(s.name)) {
          Forecast forecast = s.dates[day]!;

          Row? forecastRow = SiteForecastListView.buildForecastRow(
            context, settings, times, day, s, forecast, settings.onlyShowOn, false);

          if (forecastRow != null) {
            list.add(Divider(height: 0.0, color: Colors.black));
            list.add(InkWell(child: SiteForecastListView.buildTitleRow(context, settings, s), onTap: () {_showSite(s);}));
            list.add(InkWell(child: forecastRow, onTap: () {_showSite(s);}));

            if (settings.showForecast && (forecast.imgTitle.length > 0))
              list.add(Text(
                forecast.imgTitle, textAlign: TextAlign.center, style: Theme
                .of(context)
                .textTheme
                .bodyText1));
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
  }

  void singlePage(BuildContext context, List<Widget> pages, List<String> dates, List<String> times) {
    List<Widget> list = <Widget>[];

    for (Site s in _sites!.sites)
    {
      bool first = true;

      if(settings.showGroup == Settings.allGroup || settings.showGroup.sites.contains(s.name)) {
        int i = 0;
        for(String day in dates)
        {
          Forecast forecast = s.dates[day]!;

          Row? forecastRow = SiteForecastListView.buildForecastRow(
            context, settings, times, day, s, forecast, settings.onlyShowOn, true);

          if (forecastRow != null) {
            if(first) {
              list.add(Divider(height: 0.0, color: Colors.black));
              list.add(InkWell(child: SiteForecastListView.buildTitleRow(context, settings, s), onTap: () {_showSite(s);}));
            }
            first = false;
            list.add(InkWell(child: forecastRow, onTap: () {_showSite(s);}));

            if (settings.showForecast && (forecast.imgTitle.length > 0))
              list.add(Text(
                forecast.imgTitle, textAlign: TextAlign.center, style: Theme
                .of(context)
                .textTheme
                .bodyText1));

            ++i;
          }

          if (i >= settings.maxRows) break;
        }
      }
    }

    // If we're hiding the extreme values we might not have any rows to show.
    if(list.isNotEmpty) {
      Row timeRow = SiteForecastListView.buildTimeRow(
          context, settings, times, true, null);

      pages.add(Column(children: <Widget>[
            timeRow,
            Expanded(child: RefreshIndicator(onRefresh: _refreshForecast, child: ListView(children: list)))
          ])
      );
    }
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
    List<IconButton> actions = [];

    List<String> dates = (settings.showRASP) ? data.raspDates : data.dates;
    List<String> times = (settings.showRASP) ? data.raspTimes : data.times;

    if(site.url != null)
      actions.add(
        IconButton(icon: Icon(Icons.info, semanticLabel: "Site Info"), onPressed: (){
          setState(() {
            launch(site.url!);
          });
        }));
    actions.add(
      IconButton(icon: Icon(Icons.cloud_upload, semanticLabel: "Detailed Forecast"), onPressed: (){
        setState(() {
          launch(site.weatherURL);
        });
      }));
    if(site.obsURL != null)
      actions.add(
        IconButton(icon: Icon(Icons.cloud, color: Colors.red, semanticLabel: "Observations"), onPressed: (){
          setState(() {
            launch(site.obsURL!);
          });
        }));
    actions.add(
      IconButton(icon: Icon(Icons.trending_flat, color: settings.showBestDirection ? Colors.red : Colors.white, semanticLabel: "Best Direction"), onPressed: (){
        setState(() {
          settings.showBestDirection= !settings.showBestDirection;
        });
      }));
    actions.add(
      IconButton(icon: Icon(settings.showRASP?Icons.blur_on:Icons.blur_off, semanticLabel: "RASP"), onPressed: (){
        setState(() {
          settings.showRASP = !settings.showRASP;
        });
      }));
    actions.add(
      IconButton(icon: Icon(settings.showForecast?Icons.cloud:Icons.cloud_off, semanticLabel: "Forecast"), onPressed: (){
        setState(() {
          settings.showForecast = !settings.showForecast;
        });
      }));
    actions.add(
      IconButton(icon: Icon(Icons.settings, semanticLabel: "Settings"), onPressed: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context)
        {
          return SettingsPage(settings, widget.sites);
        }));
        setState(() {});
      }));

    return Scaffold(
      appBar: DynamicAppBar(key: UniqueKey(), context: context, actions: actions),
      body: Column(children: <Widget>[
        SiteForecastListView.buildTitleRow(context, settings, site),
        SiteForecastListView.buildTimeRow(context, settings, times, true, null),
        Expanded(child: SiteForecastListView(settings, dates, times, site))
        ])
    );
  }
}
