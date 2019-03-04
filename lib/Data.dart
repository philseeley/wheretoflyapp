import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:great_circle_distance/great_circle_distance.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Data.g.dart';

class Group {
  String name;
  bool init = false;
  List<String> sites = [];

  Group(this.name);

  Map toJson(){
    return {
      'name': name,
      'init': init,
      'sites': sites
    };
  }
}

class Settings {
  static Group allGroup = Group("ALL");

  bool showPGValues = false;
  bool showForecast = false;
  bool showMetric = false;
  bool showRASP = false;
  num iconSize = 40.0;
  bool hideExtremes = false;
  List<Group> groups = [];
  Group showGroup = allGroup;

  File _store;

  Map toJson(){
    return {
      'showPGValues': showPGValues,
      'showForecast': showForecast,
      'showMetric': showMetric,
      'iconSize': iconSize,
      'hideExtremes': hideExtremes,
      'groups': groups
    };
  }

  load() async {
    Directory directory = await path_provider.getApplicationDocumentsDirectory();
    _store = File('${directory.path}/settings.json');

    try {
      String s = _store.readAsStringSync();
      dynamic data = json.decode(s);

      if(data['showPGValues'] != null) showPGValues = data['showPGValues'];
      if(data['showForecast'] != null) showForecast = data['showForecast'];
      if(data['showMetric'  ] != null) showMetric = data['showMetric'];
      if(data['iconSize'    ] != null) iconSize = data['iconSize'];
      if(data['hideExtremes'] != null) hideExtremes = data['hideExtremes'];

      groups = [];

      if(data['groups'] != null) {
        for(var d in data['groups']){
          Group g = Group(d['name']);

          if(d['init'] != null) {
            g.init = d['init'];
            if(g.init) showGroup = g;
          }

          for(String s in d['sites'])
            g.sites.add(s);

          groups.add(g);
        }
      }

    } on FileSystemException {}
  }

  save (){
    if(_store != null)
      _store.writeAsStringSync(json.encode(this));
  }
}

@JsonSerializable()
class Data {
  final List<String> dates;
  final List<String> raspDates;
  final List<String> times;
  final List<String> raspTimes;

  Data(this.dates, this.raspDates, this.times, this.raspTimes);

  factory Data.fromJson(Map<String, dynamic> json) =>
    _$DataFromJson(json);
}

@JsonSerializable()
class Condition {
  final String dir;
  final int kts;
  final String colour;
  final String pgColour;
  final String raspColour;
  double direction;
  Color rColor;
  Color rPGColor;
  Color rRASPColor;

  static const COLOUR_MAP = {
    "Yellow": Colors.yellow,
    "LightGreen": Colors.lightGreen,
    "Orange": Colors.orange};

  static const DIRECTION_MAP = {
    'W': 0.0*pi/180.0,
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

  Condition(this.dir, this.kts, this.colour, this.pgColour, this.raspColour);

  factory Condition.fromJson(Map<String, dynamic> json) {
    Condition c = _$ConditionFromJson(json);

    c.direction = DIRECTION_MAP[c.dir];

    //c.rColor = c.rPGColor = Colors.black26;
    if(c.colour != null)
      c.rColor = COLOUR_MAP[c.colour];

    if(c.pgColour != null)
      c.rPGColor= COLOUR_MAP[c.pgColour];

    if(c.raspColour != null)
      c.rRASPColor = Color(int.parse("FF"+c.raspColour.substring(1), radix: 16));
    return c;
  }
}

@JsonSerializable()
class Forecast {
  final String img;
  CachedNetworkImage _image;
  double _imageSize;
  final String imgTitle;
  final Map<String, Condition> times;

  Forecast(this.img, this.imgTitle, this.times);

  CachedNetworkImage getImage(double imageSize) {
    if(_image == null || (_imageSize != imageSize)){
      _imageSize = imageSize;
      _image = CachedNetworkImage(imageUrl: "https://wheretofly.info/"+img, width: _imageSize, height: _imageSize);
    }

    return _image;
  }

  factory Forecast.fromJson(Map<String, dynamic> json) =>
    _$ForecastFromJson(json);
}

@JsonSerializable()
class Site {
  final String name;
  final String title;
  final double lat;
  final double lon;
  final String url;
  final String weatherURL;
  final String obsURL;
  final String minDir;
  final String maxDir;
  final int minSpeed;
  final int maxSpeed;
  final int minPGSpeed;
  final int maxPGSpeed;
  double dist;

  final Map<String,Forecast> dates;

  Site(
    this.name,
    this.title,
    this.lat,
    this.lon,
    this.url,
    this.weatherURL,
    this.obsURL,
    this.minDir,
    this.maxDir,
    this.minSpeed,
    this.maxSpeed,
    this.minPGSpeed,
    this.maxPGSpeed,
    this.dates
    );

  static sort(List<Site> sites, bool byLocation){
    if(byLocation)
      sites.sort((a, b){return (a.dist-b.dist).round();});
    else
      sites.sort((a, b){return a.title.compareTo(b.title);});
  }

  factory Site.fromJson(Map<String, dynamic> json) {
    Site s = _$SiteFromJson(json);

    var gcd = GreatCircleDistance.fromDegrees(
      latitude1: Sites.latitude, longitude1: Sites.longitude, latitude2: s.lat, longitude2: s.lon);

    s.dist = gcd.haversineDistance();

    return s;
  }
}

@JsonSerializable()
class Sites {
  final List<Site> sites;
  static double latitude;
  static double longitude;

  Sites(this.sites);

  factory Sites.fromJson(Map<String, dynamic> json, double latitude, double longitude) {
    Sites.latitude = latitude;
    Sites.longitude = longitude;

    return _$SitesFromJson(json);
  }
}
