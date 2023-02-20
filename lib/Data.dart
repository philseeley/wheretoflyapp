import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:great_circle_distance_calculator/great_circle_distance_calculator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:json_annotation/json_annotation.dart';
import 'Common.dart';

part 'Data.g.dart';

const DIRECTION_MAP = {
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


@JsonSerializable()
class Group {
  String name;
  bool init = false;
  List<String> sites;

  Group(this.name, {init, List<String>? sites}) :
    init = init ?? false,
    sites = sites ?? [];

  factory Group.fromJson(Map<String, dynamic> json) =>
    _$GroupFromJson(json);

  Map<String, dynamic> toJson() => _$GroupToJson(this);
}

@JsonSerializable()
class Settings {
  static final Group allGroup = Group("ALL");

  String version;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late bool onlyShowOn;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool sortByLocation = true;
  bool showPGValues;
  bool showMetric;
  double iconSize;
  bool hideExtremes;
  bool showDistance;
  bool singlePageView;
  int maxRows;
  bool onlyShowOnDefault;
  List<Group> groups;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool showForecast = false;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool showRASP = false;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late Group showGroup;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool showBestDirection = false;

  static File? _store;

  Settings({
    this.version = "",
    this.showPGValues = false,
    this.showMetric = false,
    this.iconSize = 40.0,
    this.hideExtremes = false,
    this.showDistance = false,
    this.singlePageView = false,
    this.maxRows = 7,
    this.onlyShowOnDefault = true,
    this.groups = const <Group>[]}) {
      onlyShowOn = onlyShowOnDefault;

      showGroup = allGroup;
      for(Group g in groups) {
        if (g.init) {
          showGroup = g;
        }
      }
  }

  factory Settings.fromJson(Map<String, dynamic> json) =>
    _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  static load() async {
    Directory directory = await path_provider.getApplicationDocumentsDirectory();
    _store = File('${directory.path}/settings.json');

    try {
      String s = _store?.readAsStringSync() ?? "";
      dynamic data = json.decode(s);

      return Settings.fromJson(data);
    } on Exception {
      return Settings();
    }
  }

  save (){
    _store?.writeAsStringSync(json.encode(toJson()));
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
  final String? dir;
  final int? kts;
  final String? colour;
  final String? pgColour;
  final String? raspColour;
  @JsonKey(includeFromJson: false, includeToJson: false)
  double? direction;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Color? rColor;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Color? rPGColor;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Color? rRASPColor;

  static const COLOUR_MAP = {
    "Yellow": Colors.yellow,
    "LightGreen": Colors.lightGreen,
    "Orange": Colors.orange};

  Condition(this.dir, this.kts, this.colour, this.pgColour, this.raspColour);

  factory Condition.fromJson(Map<String, dynamic> json) {
    Condition c = _$ConditionFromJson(json);

    // If dir is null, direction becomes null. Same with the others.
    c.direction = DIRECTION_MAP[c.dir];
    c.rColor = COLOUR_MAP[c.colour];
    c.rPGColor= COLOUR_MAP[c.pgColour];

    if(c.raspColour != null) {
      try {
        c.rRASPColor =
          Color(int.parse("FF${c.raspColour?.substring(1) ?? ""}", radix: 16));
      } on FormatException {
        // The image might not have been available and therefore the colour might be "#NaNNaNNaN".
      }
    }
    return c;
  }
}

@JsonSerializable()
class Forecast {
  final String img;
  CachedNetworkImage? _image;
  double? _imageSize;
  final String imgTitle;
  final Map<String, Condition> times;

  Forecast(this.img, this.imgTitle, this.times);

  CachedNetworkImage? getImage(double imageSize) {
    if(_image == null || (_imageSize != imageSize)){
      _imageSize = imageSize;
      _image = CachedNetworkImage(imageUrl: "$wtfURL/$img", width: _imageSize, height: _imageSize);
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
  final String? url;
  final String weatherURL;
  final String? obsURL;
  final String? minDir;
  final String? maxDir;
  final String? dir;
  final int minSpeed;
  final int maxSpeed;
  final int minPGSpeed;
  final int maxPGSpeed;
  @JsonKey(includeFromJson: false, includeToJson: false)
  double dist = 0.0;
  @JsonKey(includeFromJson: false, includeToJson: false)
  double? direction;

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
    this.dir,
    this.minSpeed,
    this.maxSpeed,
    this.minPGSpeed,
    this.maxPGSpeed,
    this.dates
    );

  static sort(List<Site> sites, bool byLocation){
    if(byLocation) {
      sites.sort((a, b){return (a.dist-b.dist).round();});
    } else {
      sites.sort((a, b){return a.title.compareTo(b.title);});
    }
  }

  factory Site.fromJson(Map<String, dynamic> json) {
    Site s = _$SiteFromJson(json);

    var gcd = GreatCircleDistance.fromDegrees(
      latitude1: Sites.latitude, longitude1: Sites.longitude, latitude2: s.lat, longitude2: s.lon);

    s.dist = gcd.haversineDistance();

    s.direction = DIRECTION_MAP[s.dir];

    return s;
  }
}

@JsonSerializable()
class Sites {
  final List<Site> sites;
  @JsonKey(includeFromJson: false, includeToJson: false)
  static double latitude = 0.0;
  @JsonKey(includeFromJson: false, includeToJson: false)
  static double longitude = 0.0;

  Sites(this.sites);

  factory Sites.fromJson(Map<String, dynamic> json, double latitude, double longitude) {
    Sites.latitude = latitude;
    Sites.longitude = longitude;

    return _$SitesFromJson(json);
  }
}
