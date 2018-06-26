import 'package:flutter/material.dart';

class Condition {
  final String dir_str;
  final double dir;
  final int kts;
  final int kms;
  final Color colour;
  final Color pgColour;

  Condition(this.dir_str, this.dir, this.kts, this.kms, this.colour, this.pgColour);
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
  final String url;
  final String weather_url;
  final String obs_url;

  final List<Forecast> forecasts = new List<Forecast>();

  Site(this.name, this.title, this.lat, this.lon, this.url, this.weather_url, this.obs_url);
}
