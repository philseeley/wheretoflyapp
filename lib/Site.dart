import 'package:flutter/material.dart';

class Condition {
  final String dirStr;
  final double dir;
  final int kts;
  final int kms;
  final Color colour;
  final Color pgColour;

  Condition(this.dirStr, this.dir, this.kts, this.kms, this.colour, this.pgColour);
}

class Forecast {
  final DateTime date;
  final String image;
  final String imgTitle;
  final List<Condition> conditions = new List<Condition>();

  Forecast(this.date, this.image, this.imgTitle);
}

class Site {
  final String name;
  final String title;
  final double lat;
  final double lon;
  final double dist;
  final String url;
  final String weatherURL;
  final String obsURL;

  final List<Forecast> forecasts = new List<Forecast>();

  Site(this.name, this.title, this.lat, this.lon, this.dist, this.url, this.weatherURL, this.obsURL);
}
