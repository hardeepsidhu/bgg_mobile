import 'package:bgg_mobile/ui/routes.dart';
import 'package:bgg_mobile/ui/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:bgg_mobile/network/api.dart';
import 'package:bgg_mobile/ui/widgets/boardgame_cell.dart';
import 'package:bgg_mobile/ui/pages/boardgame_details.dart';
import 'package:bgg_mobile/ui/widgets/future_widget_builder.dart';

class HotPage extends StatelessWidget {
  static const String routeName = '/hot';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text('Hot'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: _BoardgameSearchDelegate(),
                );
              },
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: _HotWidget()
    );
  }
}

class _HotWidget extends StatefulWidget {
  @override
  createState() => new _HotWidgetState();
}

class _HotWidgetState extends State<_HotWidget> {
  Future _future;

  @override
  Widget build(BuildContext context) {
    if (_future == null) {
      _future = Api.get().getHot();
    }

    return FutureWidgetBuilder.buildListView((context, index, obj) {
      return new FlatButton(
        child: new BoardgameCell(obj, rank: index + 1),
        padding: const EdgeInsets.all(0.0),
        color: Colors.white,
        onPressed: () {
          Navigator.pushNamed(
            context,
            Routes.boardgame_details,
            arguments: BoardgameDetailsArguments(obj),
          );
        },
      );
    }, _future);
  }
}

class _BoardgameSearchDelegate extends SearchDelegate {
  Future _future;
  String _prevQuery;

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return null;
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 1) {
      return Column();
    }
    else {
      if (_future == null || query != _prevQuery) {
        _prevQuery = query;
        _future = Api.get().search(query);
      }

      return FutureWidgetBuilder.buildListView((context, index, obj) {
        return new FlatButton(
          child: new BoardgameCell(obj),
          padding: const EdgeInsets.all(0.0),
          color: Colors.white,
          onPressed: () {
            Navigator.pushNamed(
              context,
              Routes.boardgame_details,
              arguments: BoardgameDetailsArguments(obj),
            );
          },
        );
      }, _future);
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column();
  }
}