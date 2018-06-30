import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Site.dart';

class SiteForecastListView extends StatefulWidget {
  static final dayF = new DateFormat('EEE');

  final Site site;

  SiteForecastListView(this.site);

  @override
  _SiteForecastListViewState createState() => new _SiteForecastListViewState();

  static Row buildForecastRow(BuildContext context, Forecast forecast, bool showDay) {
    List<Widget> lts = new List<Widget>();

    for (Condition c in forecast.conditions){
      Widget lt = Expanded(child:
      new Stack(alignment: AlignmentDirectional.center, children: <Widget>[
        new Transform.rotate(angle: c.dir == null?0.0:c.dir, child: new Icon(Icons.forward, color: (c.kts==0)?Colors.white:c.colour, size: 40.0, )),
        new Text((c.kts==0)?"":c.kts.toString(), style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 4),)
      ],)
      );
      lts.add(lt);
    }

    if(showDay) {
      return new Row(children: <Widget>[
        new Expanded(child: new Text(dayF.format(forecast.date), style: Theme
                .of(context)
                .textTheme
                .subhead
                .apply(fontWeightDelta: 4))),
        new Expanded(flex: 4, child: new Row(children: lts)),
      ]);
    }
    else {
      return new Row(children: lts);
    }
  }
}

class _SiteForecastListViewState extends State<SiteForecastListView> {

  Site site;

  @override
  Widget build(BuildContext context) {
    site = widget.site;

    List<Widget> list = new List<Widget>();

    for(Forecast f in site.forecasts){
      list.add(SiteForecastListView.buildForecastRow(context, f, true));
    }

    return new ListView(children: list);
  }
}
