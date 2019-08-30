import 'package:flutter/material.dart';

class ReleaseNotesPage extends StatelessWidget {

  static const changelog = {
    "6.1.1": "Fixed a bug where selecting 'Show Paragliding Values' hides all sites - thanks to Greg K for reporting this.",
    "6.1.0": """Added divider in main list to better show which arrows are for which site - thanks Tushar P for the idea.

Added help for arrow colours - thanks Darryl B for pointing out this was missing.

If the mailto: URL is not supported by the phone, we now open the website info page.

As RASP is nolonger available, this option has been removed. Hopfully an alternative can be found.""",
    "6.0.0": """Added option to display the Thermal Updraft Velocity from RASP - thanks Dave M for the idea.

Added option to show the best direction for each site - thanks Darryl V for the idea.""",
    "5.10":  "Fixed group loading issue. Add distance to sites - thanks Greg K for the idea",
    "5.9":   "Pulling down now refeshes the data. We now show the group list instead of the title.",
    "5.8":   "Added a share button - thanks Rob VDK for the idea.",
    "5.7":   "We now allow a site not to have an information page. Tapping the site name now also opens the site page - thanks Rob VDK for the idea.",
    "5.6":   "Added option to set a default group.",
    "5.5":   "If the location is not available, we now sort by site.",
    "5.4":   "Fixed issue with no forecast being available from BOM.",
    "5.3":   "Fixed issue with the BOM missing data.",
    "5.2":   "Added help page.",
    "5.1":   "Updated icon.",
    "5.0":   "Added option to show metric values.",
    "4.0":   "Added groups and option to hide early/late values.",
    "3.0":   "The forecast is now shown even if the location cannot be obtained. Added option to vary icon size.",
    "2.1":   "Added message whilst waiting for data and location.",
    "2.0":   "Added option to show weather forecats and included weather icons. Added option to show Paraglider values - thanks Cliff D and Phil L for the idea.",
    "1.0":   "Thanks to Kimi S for the initial idea.",
  };

  final String title;
  ReleaseNotesPage(this.title);

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    changelog.forEach((k, v) {
      list.add(Text("Version "+k, style: Theme
        .of(context)
        .textTheme
        .title.apply(color: Colors.blue)));
      list.add(Container(child: Text(v), padding: EdgeInsets.all(4)));
    });

    return(Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(padding: EdgeInsets.all(4), children: list)
    ));
  }
}
