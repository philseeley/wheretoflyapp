import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Data.dart';

class SiteForecastListView extends StatefulWidget {
  static final dayF = DateFormat('EEE');

  final Site site;
  final Settings settings;
  final List<String> dates;
  final List<String> times;

  SiteForecastListView(this.settings, this.dates, this.times, this.site);

  @override
  _SiteForecastListViewState createState() => _SiteForecastListViewState();

  static Row buildForecastRow(BuildContext context, Settings settings, List<String> times, String day, Site s, Forecast forecast, bool onlyIfOn, bool showDay) {
    bool on = false;

    List<Widget> list = List<Widget>();

    if(showDay)
      list.add(Expanded(child: Text(dayF.format(DateTime.parse(day)).substring(0, 2), textAlign: TextAlign.center)));

    list.add(Expanded(child: forecast.getImage(settings.iconSize)));

    for (int t=0; t<times.length; ++t) {
      Condition c = forecast.times[times[t]];

      if(c != null){
        if (!settings.hideExtremes ||
//          (t > 1 && t < times.length - (settings.showRASP ? 2 : 1))) {
          (t > 1 && t < times.length - 1)) {
          Color colour = settings.showPGValues ? c.rPGColor : c.rColor;
          if(colour != null)
            on = true;

          if(colour == null && c.kts != null)
            colour = Colors.grey;

          int speed = c.kts ?? 0;
          if (settings.showMetric)
            speed = (speed * 1.85).round();

//          Color raspColour = (settings.showRASP && c.rRASPColor != null) ? c.rRASPColor : Theme.of(context).canvasColor;
          Color raspColour = Theme.of(context).canvasColor;

          List<Widget> icons = <Widget>[];

          icons.add(Icon(Icons.lens, color: raspColour, size: settings.iconSize));

          if(colour != null)
            icons.add(Transform.rotate(
              angle: c.direction ?? 0,
              child: Icon(Icons.forward, color: colour, size: settings.iconSize)
            ));

          if (settings.showBestDirection && c.kts != null)
            icons.add(Transform.rotate(
              angle: s.direction != null ? (s.direction) : 0,
              child: Icon(
                Icons.trending_flat, color: Colors.red, size: settings.iconSize
              )));

          if (speed != 0)
            icons.add(Text(speed.toString()));

          Widget lt = Expanded(child:
            Stack(alignment: AlignmentDirectional.center, children: icons));

          list.add(lt);
        }
      }
    }

    // Sometimes the forecast is not downloaded from the BOM correctly, so there will be no conditions.
    if((forecast.times.length == 0) || (onlyIfOn && !on))
      return null;

    return Row(children: list);
  }

  static Row buildTimeRow(BuildContext context, Settings settings, List<String> times, bool includeDay, String date) {
    List<Widget> dateW = List<Widget>();

    if(includeDay)
      dateW.add(Expanded(child: Text("", textAlign: TextAlign.center)));

    String day = (date == null) ? "" : dayF.format(DateTime.parse(date)).substring(0, 2);

    dateW.add(Expanded(child: Text(day, textAlign: TextAlign.center)));

    for(int i=0; i<times.length; ++i) {
      String t = times[i];

//      if(!settings.hideExtremes || (i>1 && i<times.length-(settings.showRASP?2:1)))
      if(!settings.hideExtremes || (i>1 && i<times.length-1))
        dateW.add(Expanded(child: Text(t, textAlign: TextAlign.center)));
    }

    return Row(children: dateW);
  }

  static Row buildTitleRow(BuildContext context, Settings settings, Site site) {
    String speed = site.dir+" "+site.minDir+"-"+site.maxDir+" ";

    int minSpeed = (settings.showPGValues) ? site.minPGSpeed : site.minSpeed;
    int maxSpeed = (settings.showPGValues) ? site.maxPGSpeed : site.maxSpeed;

    if(settings.showMetric)
    {
      minSpeed = (minSpeed*1.85).round();
      maxSpeed = (maxSpeed*1.85).round();
    }

    speed += minSpeed.toString()+"-"+maxSpeed.toString();
    speed += (settings.showMetric) ? " kmh" : " kts";

    if(settings.showDistance)
      speed += " ${site.dist~/1000} km";

    return Row(children: <Widget>[
      Expanded(child: Text(site.title, textAlign: TextAlign.center)),
      Expanded(child: Text(speed, textAlign: TextAlign.center, style: Theme.of(context).textTheme.body2))
    ]);
  }
}

class _SiteForecastListViewState extends State<SiteForecastListView> {

  @override
  Widget build(BuildContext context) {
    Settings settings = widget.settings;
    Site site = widget.site;
    final List<String> dates = widget.dates;
    final List<String> times = widget.times;

    List<Widget> list = List<Widget>();

    for(String day in dates){
      Forecast f = site.dates[day];

      Row forecastRow = SiteForecastListView.buildForecastRow(context, settings, times, day, site, f, false, true);

      if(forecastRow != null){
        list.add(forecastRow);

        if(settings.showForecast && (f.imgTitle.length > 0))
          list.add(Text(f.imgTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.body2));
      }
    }

    return ListView(children: list);
  }
}
