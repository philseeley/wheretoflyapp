// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) {
  return Group(
    json['name'] as String,
    init: json['init'],
    sites: (json['sites'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'name': instance.name,
      'init': instance.init,
      'sites': instance.sites,
    };

Settings _$SettingsFromJson(Map<String, dynamic> json) {
  return Settings(
    version: json['version'],
    showPGValues: json['showPGValues'],
    showMetric: json['showMetric'],
    iconSize: json['iconSize'],
    hideExtremes: json['hideExtremes'],
    showDistance: json['showDistance'],
    showOnDefault: json['showOnDefault'],
    groups: (json['groups'] as List)
        .map((e) => Group.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'version': instance.version,
      'showPGValues': instance.showPGValues,
      'showMetric': instance.showMetric,
      'iconSize': instance.iconSize,
      'hideExtremes': instance.hideExtremes,
      'showDistance': instance.showDistance,
      'showOnDefault': instance.onlyShowOnDefault,
      'groups': instance.groups,
    };

Data _$DataFromJson(Map<String, dynamic> json) {
  return Data(
    (json['dates'] as List)?.map((e) => e as String)?.toList(),
    (json['raspDates'] as List)?.map((e) => e as String)?.toList(),
    (json['times'] as List)?.map((e) => e as String)?.toList(),
    (json['raspTimes'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'dates': instance.dates,
      'raspDates': instance.raspDates,
      'times': instance.times,
      'raspTimes': instance.raspTimes,
    };

Condition _$ConditionFromJson(Map<String, dynamic> json) {
  return Condition(
    json['dir'] as String,
    json['kts'] as int,
    json['colour'] as String,
    json['pgColour'] as String,
    json['raspColour'] as String,
  );
}

Map<String, dynamic> _$ConditionToJson(Condition instance) => <String, dynamic>{
      'dir': instance.dir,
      'kts': instance.kts,
      'colour': instance.colour,
      'pgColour': instance.pgColour,
      'raspColour': instance.raspColour,
    };

Forecast _$ForecastFromJson(Map<String, dynamic> json) {
  return Forecast(
    json['img'] as String,
    json['imgTitle'] as String,
    (json['times'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : Condition.fromJson(e as Map<String, dynamic>)),
    ),
  );
}

Map<String, dynamic> _$ForecastToJson(Forecast instance) => <String, dynamic>{
      'img': instance.img,
      'imgTitle': instance.imgTitle,
      'times': instance.times,
    };

Site _$SiteFromJson(Map<String, dynamic> json) {
  return Site(
    json['name'] as String,
    json['title'] as String,
    (json['lat'] as num)?.toDouble(),
    (json['lon'] as num)?.toDouble(),
    json['url'] as String,
    json['weatherURL'] as String,
    json['obsURL'] as String,
    json['minDir'] as String,
    json['maxDir'] as String,
    json['dir'] as String,
    json['minSpeed'] as int,
    json['maxSpeed'] as int,
    json['minPGSpeed'] as int,
    json['maxPGSpeed'] as int,
    (json['dates'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : Forecast.fromJson(e as Map<String, dynamic>)),
    ),
  );
}

Map<String, dynamic> _$SiteToJson(Site instance) => <String, dynamic>{
      'name': instance.name,
      'title': instance.title,
      'lat': instance.lat,
      'lon': instance.lon,
      'url': instance.url,
      'weatherURL': instance.weatherURL,
      'obsURL': instance.obsURL,
      'minDir': instance.minDir,
      'maxDir': instance.maxDir,
      'dir': instance.dir,
      'minSpeed': instance.minSpeed,
      'maxSpeed': instance.maxSpeed,
      'minPGSpeed': instance.minPGSpeed,
      'maxPGSpeed': instance.maxPGSpeed,
      'dates': instance.dates,
    };

Sites _$SitesFromJson(Map<String, dynamic> json) {
  return Sites(
    (json['sites'] as List)
        ?.map(
            (e) => e == null ? null : Site.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$SitesToJson(Sites instance) => <String, dynamic>{
      'sites': instance.sites,
    };
