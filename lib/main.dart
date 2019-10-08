// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:bgg_mobile/ui/pages/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:bgg_mobile/ui/pages/articles.dart';
import 'package:bgg_mobile/ui/pages/boardgame_details.dart';
import 'package:bgg_mobile/ui/pages/collection_list.dart';
import 'package:bgg_mobile/ui/pages/forums.dart';
import 'package:bgg_mobile/ui/pages/hot_page.dart';
import 'package:bgg_mobile/ui/pages/settings_page.dart';
import 'package:bgg_mobile/ui/pages/subscriptions_page.dart';
import 'package:bgg_mobile/ui/pages/threads.dart';
import 'package:bgg_mobile/ui/routes.dart';
import 'package:bgg_mobile/settings/settings.dart';

void main() async {
  await Settings.get().load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BGG Mobile',
      home: HotPage(),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case Routes.articles:
            return CupertinoPageRoute(
                builder: (_) => Articles(), settings: settings);
          case Routes.boardgame_details:
            return CupertinoPageRoute(
                builder: (_) => BoardgameDetails(), settings: settings);
          case Routes.collection_list:
            return CupertinoPageRoute(
                builder: (_) => CollectionList(), settings: settings);
          case Routes.collection:
            return CupertinoPageRoute(
                builder: (_) => Collection(), settings: settings);
          case Routes.forums:
            return CupertinoPageRoute(
                builder: (_) => Forums(), settings: settings);
          case Routes.hot_page:
            return CupertinoPageRoute(
                builder: (_) => HotPage(), settings: settings);
          case Routes.settings_page:
            return CupertinoPageRoute(
                builder: (_) => SettingsPage(), settings: settings);
          case Routes.subscriptions_page:
            return CupertinoPageRoute(
                builder: (_) => SubscriptionsPage(), settings: settings);
          case Routes.threads:
            return CupertinoPageRoute(
                builder: (_) => Threads(), settings: settings);
        }

        return null;
      },
    );
  }
}
