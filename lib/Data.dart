import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:great_circle_distance/great_circle_distance.dart';

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

final _dirs = {'W': 0.0*pi/180.0,
  'WNW': 22.5*pi/180.0,
  'NW': 45.0*pi/180.0,
  'NNW': 67.5*pi/180.0,
  'N': 90.0*pi/180.0,
  'NNE': 112.5*pi/180.0,
  'NE': 135.0*pi/180.0,
  'ENE': 157.5*pi/180.0,
  'E': 180.0*pi/180.0,
  'ESE': 202.5*pi/180.0,
  'SE': 225.0*pi/180.0,
  'SSE': 247.5*pi/180.0,
  'S': 270.0*pi/180.0,
  'SSW': 292.5*pi/180.0,
  'SW': 315.0*pi/180.0,
  'WSW': 337.5*pi/180.0};

List<Site> parseSites(dynamic data, double latitude, double longitude) {
  List<Site> sites = new List<Site>();

  for (var s in data['sites']) {
    num lat = s['lat'];
    num lon = s['lon'];
    var gcd = new GreatCircleDistance.fromDegrees(
        latitude1: latitude, longitude1: longitude, latitude2: lat.toDouble(), longitude2: lon.toDouble());
    double dist =gcd.haversineDistance();

    var site = new Site(
      s['name'],
      s['title'],
      lat.toDouble(),
      lon.toDouble(),
      dist,
      s['url'],
      s['weather_url'],
      s['obs_url'],
    );
    sites.add(site);

    for(var f in s['forecast']){
      var forecast = new Forecast(DateTime.parse(f['date']), f['img'], f['imgTitle']);
      site.forecasts.add(forecast);

      for(var c in f['conditions']){
        int kts = 0;
        try
        {
          kts = int.parse(c['kts']);
        } catch(e){}
        int kms = 0;
        try
        {
          kms = int.parse(c['kms']);
        } catch(e){}

        Color colour = Colors.black26;
        switch(c['colour'])
        {
          case "Yellow":
            colour = Colors.yellow;
            break;
          case "LightGreen":
            colour = Colors.lightGreen;
            break;
          case "Orange":
            colour = Colors.orange;
            break;
        }

        Color pgColour = Colors.black26;
        switch(c['PGColour'])
        {
          case "Yellow":
            pgColour = Colors.yellow;
            break;
          case "LightGreen":
            pgColour = Colors.lightGreen;
            break;
          case "Orange":
            pgColour = Colors.orange;
            break;
        }

        var condition = new Condition(c['dir'], _dirs[c['dir']], kts, kms, colour, pgColour);
        forecast.conditions.add(condition);
      }
    }
  }

  return sites;
}
