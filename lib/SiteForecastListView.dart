import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Data.dart';

class SiteForecastListView extends StatefulWidget {
  static final dayF = new DateFormat('EEE');

  final Site site;
  final Settings settings;

  SiteForecastListView(this.settings, this.site);

  @override
  _SiteForecastListViewState createState() => new _SiteForecastListViewState();

  static Row buildForecastRow(BuildContext context, Settings settings, Forecast forecast, bool onlyIfOn, bool showDay) {
    bool on = false;

    List<Widget> lts = new List<Widget>();

    if(showDay)
      lts.add(new Expanded(child: new Text(dayF.format(forecast.date), textAlign: TextAlign.center, style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 4))));

    for (Condition c in forecast.conditions){
      Color colour = settings.showPGValues ? c.pgColour : c.colour;
      int speed = settings.showPGValues ? c.kmh : c.kts;

      if(colour != Colors.black26)
        on = true;

      Widget lt = Expanded(child:
      new Stack(alignment: AlignmentDirectional.center, children: <Widget>[
        new Transform.rotate(angle: c.dir == null?0.0:c.dir, child: new Icon(Icons.forward, color: (speed==0)?Colors.white:c.colour, size: 40.0)),
        new Text((speed==0)?"":speed.toString(), style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 4))
      ],)
      );
      lts.add(lt);
    }

    if(onlyIfOn && !on)
      return null;

    return new Row(children: lts);
  }

  static Row buildTimeRow(BuildContext context, List<String> times, bool includeDay) {
    List<Widget> dateW = new List<Widget>();

    if(includeDay)
      dateW.add(new Expanded(child: new Text("", textAlign: TextAlign.center, style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 4))));

    for(String t in times)
      dateW.add(new Expanded(child: new Text(t, textAlign: TextAlign.center, style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 4))));

    return new Row(children: dateW);
  }
}

class _SiteForecastListViewState extends State<SiteForecastListView> {

  @override
  Widget build(BuildContext context) {
    Settings settings = widget.settings;
    Site site = widget.site;

    List<Widget> list = new List<Widget>();

    for(Forecast f in site.forecasts){
      list.add(SiteForecastListView.buildForecastRow(context, settings, f, false, true));
    }

    return new ListView(children: list);
  }
}
