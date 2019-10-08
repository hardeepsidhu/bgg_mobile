import 'package:bgg_mobile/settings/settings.dart';
import 'package:bgg_mobile/ui/routes.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var drawerItems = generateDrawerItems();

    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            height: 60.0,
            child: DrawerHeader(
              child: Text(
                "BGG Mobile",
                style: TextStyle(color: Colors.white),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: drawerItems.length,
            itemBuilder: (BuildContext context, int index) {
              DrawerItem item = drawerItems[index];
              return ListTile(
                  leading: Icon(
                    item.icon,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(),
                  ),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, item.route);
                  });
            },
          ),
        ],
      ),
    );
  }

  List<DrawerItem> generateDrawerItems() {
    List<DrawerItem> drawerItems = new List();

    drawerItems.add(DrawerItem(Icons.storage, 'Games', Routes.hot_page));

    if (Settings.get().username.length > 0 && Settings.get().password.length > 0) {
      drawerItems.add(DrawerItem(Icons.subscriptions, 'Subscriptions', Routes.subscriptions_page));
    }

    drawerItems.add(DrawerItem(Icons.forum, 'Forums', Routes.forums));
    drawerItems.add(DrawerItem(Icons.collections, 'Collection', Routes.collection));
    drawerItems.add(DrawerItem(Icons.settings, 'Settings', Routes.settings_page));

    return drawerItems;
  }
}

class DrawerItem {
  final IconData icon;
  final String title;
  final String route;

  DrawerItem(this.icon, this.title, this.route);
}