import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'common.dart';
import 'data.dart';

class SiteForecastListView extends StatefulWidget {
  static final dayF = DateFormat('EEE');

  final Site site;
  final Settings settings;
  final List<String> dates;
  final List<String> times;

  const SiteForecastListView(this.settings, this.dates, this.times, this.site, {super.key});

  @override
  createState() => _SiteForecastListViewState();

  static Row? buildForecastRow(BuildContext context, Settings settings, List<String> times, String day, Site s, Forecast forecast, bool onlyIfOn, bool showDay) {
    bool on = false;

    List<Widget> list = <Widget>[];

    if(showDay) {
      list.add(Expanded(child: Text(dayF.format(DateTime.parse(day)).substring(0, 2), textAlign: TextAlign.center)));
    }

    list.add(Expanded(child: forecast.getImage(settings.iconSize) as Widget));

    for (int t=0; t<times.length; ++t) {
      Condition? c = forecast.times[times[t]];

      if(c != null){
        if (!settings.hideExtremes ||
          (t > 1 && t < times.length - (settings.showRASP ? 2 : 1))) {
          Color? colour = settings.showPGValues ? c.rPGColor : c.rColor;
          if(colour != null) {
            on = true;
          }

          if(colour == null && c.kts != null) {
            colour = Colors.grey;
          }

          int speed = c.kts ?? 0;
          if (settings.showMetric) {
            speed = (speed * 1.85).round();
          }

          Color? raspColour = (settings.showRASP && c.rRASPColor != null) ? c.rRASPColor : Theme.of(context).canvasColor;

          List<Widget> icons = <Widget>[];

          icons.add(Icon(Icons.lens, color: raspColour, size: settings.iconSize));

          if(colour != null) {
            if(settings.enhanceOnSites) {
              icons.add(Icon(outlineIconMap[colour], size: settings.iconSize));
            }
            icons.add(Transform.rotate(
                angle: c.direction!,
                child: Icon(Icons.forward, color: colour, size: settings.iconSize)
            ));
          }

          if (settings.showBestDirection && c.kts != null && s.direction != null) {
            icons.add(Transform.rotate(
              angle: s.direction!,
              child: Icon(
                Icons.trending_flat, color: Colors.red, size: settings.iconSize
              )));
          }

          if (speed != 0) {
            icons.add(Text(speed.toString()));
          }

          Widget lt = Expanded(child:
            Stack(alignment: AlignmentDirectional.center, children: icons));

          list.add(lt);
        }
      }
    }

    // Sometimes the forecast is not downloaded from the BOM correctly, so there will be no conditions.
    if((forecast.times.isEmpty) || (onlyIfOn && !on)) {
      return null;
    }

    return Row(children: list);
  }

  static Row buildTimeRow(BuildContext context, Settings settings, List<String> times, bool includeDay, String? date) {
    List<Widget> dateW = <Widget>[];

    if(includeDay) {
      dateW.add(const Expanded(child: Text("", textAlign: TextAlign.center)));
    }

    String day = (date == null) ? "" : dayF.format(DateTime.parse(date)).substring(0, 2);

    dateW.add(Expanded(child: Text(day, textAlign: TextAlign.center)));

    for(int i=0; i<times.length; ++i) {
      String t = times[i];

      if(!settings.hideExtremes || (i>1 && i<times.length-(settings.showRASP?2:1))) {
        dateW.add(Expanded(child: Text(t, textAlign: TextAlign.center)));
      }
    }

    return Row(children: dateW);
  }

  static Row buildTitleRow(BuildContext context, Settings settings, Site site) {
    String speed = "";
    if (site.minDir != null) speed = "${site.dir} ${site.minDir}-${site.maxDir} ";

    int minSpeed = (settings.showPGValues) ? site.minPGSpeed : site.minSpeed;
    int maxSpeed = (settings.showPGValues) ? site.maxPGSpeed : site.maxSpeed;

    if(settings.showMetric)
    {
      minSpeed = (minSpeed*1.85).round();
      maxSpeed = (maxSpeed*1.85).round();
    }

    speed += "$minSpeed-$maxSpeed";
    speed += (settings.showMetric) ? " kmh" : " kts";

    if(settings.showDistance) {
      speed += " ${site.dist~/1000} km";
    }

    return Row(children: <Widget>[
      Expanded(child: InkWell(onTap: (site.url == null) ? null : () {openUrl(site.url!);}, child: Text(site.title, textAlign: TextAlign.center))),
      Expanded(child: Text(speed, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge))
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

    List<Widget> list = <Widget>[];

    for(String day in dates){
      Forecast f = site.dates[day]!;

      Row? forecastRow = SiteForecastListView.buildForecastRow(context, settings, times, day, site, f, false, true);

      if(forecastRow != null){
        list.add(forecastRow);

        if(settings.showForecast && (f.imgTitle.isNotEmpty)) {
          list.add(Text(f.imgTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge));
        }
      }
    }

    return ListView(children: list);
  }
}
