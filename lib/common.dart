import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const String wtfSite = 'wheretofly.info';
const String wtfSitePort = wtfSite;
const String wtfURL = 'https://$wtfSitePort';

Map<Color, IconData> outlineIconMap = {
  Colors.grey: Icons.wifi_1_bar_rounded,
  Colors.yellow: Icons.filter_tilt_shift,
  Colors.lightGreen: Icons.brightness_1_outlined,
  Colors.orange: Icons.brightness_1};

openUrl(String url) async {
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
