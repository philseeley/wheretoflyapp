import 'package:flutter/material.dart';

class DynamicAppBar extends AppBar{

  DynamicAppBar({
    Key key,
    title,
    @required BuildContext context,
    @required List<IconButton> actions,
    double actionsPercent = 0.75
  }): super(key: key, title: title, actions: _actions(context, actions, actionsPercent));

  static List<Widget> _actions(BuildContext context, List<IconButton> actions, double actionsPercent){

    int numIcons = (MediaQuery.of(context).size.width*actionsPercent/48).floor();

    if(actions.length <= numIcons)
      return actions;

    List<Widget> dynamicActions = [];

    int i;
    for(i=0; i<numIcons-1; ++i)
      dynamicActions.add(actions[i]);

    List<PopupMenuItem<VoidCallback>> menuActions = [];

    for (; i < actions.length; ++i) {
      Icon icon = actions[i].icon;

      menuActions.add(PopupMenuItem<VoidCallback>(
        child: ListTile(
          leading: Icon(icon.icon, color: icon.color ?? Colors.white),
          title: Text(icon.semanticLabel ?? ""),
        ),
        value: actions[i].onPressed,
      ));
    }

    dynamicActions.add(Theme(data: ThemeData(cardColor: Colors.blue, iconTheme: IconThemeData(color: Colors.white)), child:
      PopupMenuButton<VoidCallback>(
        itemBuilder: (BuildContext context) {
          return menuActions;
        },
        onSelected: (VoidCallback value) {
          if (value != null)
            value();
        })
    ));

    return dynamicActions;
  }
}