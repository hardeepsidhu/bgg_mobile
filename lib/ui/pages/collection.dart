import 'dart:collection';

import 'package:bgg_mobile/models/collection_item.dart';
import 'package:bgg_mobile/network/api.dart';
import 'package:bgg_mobile/settings/settings.dart';
import 'package:bgg_mobile/ui/pages/collection_list.dart';
import 'package:bgg_mobile/ui/helper.dart';
import 'package:bgg_mobile/ui/routes.dart';
import 'package:bgg_mobile/ui/widgets/drawer.dart';
import 'package:bgg_mobile/ui/widgets/future_widget_builder.dart';
import 'package:flutter/material.dart';

class Collection extends StatelessWidget {
  static const String routeName = '/collection';

  @override
  Widget build(BuildContext context) {
    String username = Settings.get().username;
    String title = 'Collection';

    if (username != null && username.length > 0) {
      title = 'My Collection';
    }

    return new Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.people),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: _CollectionSearchDelegate(),
                );
              },
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: _Collection(username)
    );
  }
}

class _Collection extends StatefulWidget {
  final String username;
  final bool validUsername;

  _Collection(String username) :
        username = username,
        validUsername = (username != null && username.length > 0);

  @override
  createState() => new _CollectionState();
}

class _CollectionState extends State<_Collection> {
  Future _future;

  List<CollectionItem> _all;
  List<CollectionItem> _games;

  List<CollectionItem> _owned = new List();
  List<CollectionItem> _solo = new List();
  List<CollectionItem> _twoPlayer = new List();
  List<CollectionItem> _threePlayer = new List();
  List<CollectionItem> _fourPlayer = new List();
  List<CollectionItem> _fivePlayer = new List();
  List<CollectionItem> _sixPlayer = new List();
  List<CollectionItem> _sevenPlayer = new List();
  List<CollectionItem> _expansions = new List();
  List<CollectionItem> _wishlist = new List();
  List<CollectionItem> _allOwnedItems = new List();
  List<CollectionItem> _allRatedItems = new List();
  List<CollectionItem> _allItems = new List();

  @override
  Widget build(BuildContext context) {
    if (_future == null && widget.validUsername) {
      _future = getCollection(widget.username);
    }

    return _collectionBody();
  }

  Widget _collectionBody() {
    if (!widget.validUsername) {
      return Column();
    }
    else {
      return FutureWidgetBuilder.buildListViewSeparated((context, index, obj) {
        String text;

        if (obj == _owned) {
          text = 'Owned';
        } else if (obj == _solo) {
          text = '          Solo';
        } else if (obj == _twoPlayer) {
          text = '          2 Player';
        } else if (obj == _threePlayer) {
          text = '          3 Player';
        } else if (obj == _fourPlayer) {
          text = '          4 Player';
        } else if (obj == _fivePlayer) {
          text = '          5 Player';
        } else if (obj == _sixPlayer) {
          text = '          6 Player';
        } else if (obj == _sevenPlayer) {
          text = '          7+ Player';
        } else if (obj == _expansions) {
          text = 'Expansions';
        } else if (obj == _wishlist) {
          text = 'Wishlist';
        } else if (obj == _allOwnedItems) {
          text = 'All Owned';
        } else if (obj == _allRatedItems) {
          text = 'All Rated';
        } else if (obj == _allItems) {
          text = 'All';
        }

        text += ' (' + obj.length.toString() + ')';

        return new FlatButton(
          child: Padding(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    textAlign: TextAlign.left,
                    style: UIHelper.textStyle(),
                  ),
                ),
              ],
            ),
          ),
          padding: const EdgeInsets.all(0.0),
          onPressed: () {
            Navigator.pushNamed(
              context,
              Routes.collection_list,
              arguments: CollectionListArguments(text, obj),
            );
          },
        );
      }, _future);
    }
  }

  Future<List<List<CollectionItem>>> getCollection(String username) async {
    _all = await Api.get().getCollection(username, true);
    _games = await Api.get().getCollection(username, false);

    _owned.clear();
    _solo.clear();
    _twoPlayer.clear();
    _threePlayer.clear();
    _fourPlayer.clear();
    _fivePlayer.clear();
    _sixPlayer.clear();
    _sevenPlayer.clear();
    _expansions.clear();
    _wishlist.clear();
    _allOwnedItems.clear();
    _allRatedItems.clear();
    _allItems.clear();

    HashSet gamesSet = new HashSet();
    for (CollectionItem item in _games) {
      gamesSet.add(item.game.id);
    }

    for (CollectionItem item in _all) {
      _allItems.add(item);

      if (item.owned) {
        _allOwnedItems.add(item);

        if (!gamesSet.contains(item.game.id)) {
          _expansions.add(item);
        }
      }

      if (item.wishlist) {
        _wishlist.add(item);
      }

      if (item.rating != null && item.rating > 0) {
        _allRatedItems.add(item);
      }
    }

    _allRatedItems.sort((item1, item2) {
      if (item1.rating > item2.rating) {
        return -1;
      } else if (item1.rating < item2.rating) {
        return 1;
      } else {
        return item1.game.name.compareTo(item2.game.name);
      }
    });

    for (CollectionItem item in _games) {
      if (item.owned) {
        _owned.add(item);

        int minPlayers = item.game.minPlayers;
        int maxPlayers = item.game.maxPlayers;

        for (var expansion in _expansions) {
          if (expansion.game.name.startsWith(item.game.name)) {
            // Assume this is an expansion for the current game
            if (expansion.game.minPlayers < minPlayers) {
              minPlayers = expansion.game.minPlayers;
            }

            if (expansion.game.maxPlayers > maxPlayers) {
              maxPlayers = expansion.game.maxPlayers;
            }
          }
        }

        if (minPlayers == 1) {
          _solo.add(item);
        }

        if (minPlayers <= 2 && maxPlayers >= 2) {
          _twoPlayer.add(item);
        }

        if (minPlayers <= 3 && maxPlayers >= 3) {
          _threePlayer.add(item);
        }

        if (minPlayers <= 4 && maxPlayers >= 4) {
          _fourPlayer.add(item);
        }

        if (minPlayers <= 5 && maxPlayers >= 5) {
          _fivePlayer.add(item);
        }

        if (minPlayers <= 6 && maxPlayers >= 6) {
          _sixPlayer.add(item);
        }

        if (maxPlayers >= 7) {
          _sevenPlayer.add(item);
        }
      }
    }

    List<List<CollectionItem>> collectionList = new List();

    if (_owned.length > 0) {
      collectionList.add(_owned);

      if (_solo.length > 0) {
        collectionList.add(_solo);
      }

      if (_twoPlayer.length > 0) {
        collectionList.add(_twoPlayer);
      }

      if (_threePlayer.length > 0) {
        collectionList.add(_threePlayer);
      }

      if (_fourPlayer.length > 0) {
        collectionList.add(_fourPlayer);
      }

      if (_fivePlayer.length > 0) {
        collectionList.add(_fivePlayer);
      }

      if (_sixPlayer.length > 0) {
        collectionList.add(_sixPlayer);
      }

      if (_sevenPlayer.length > 0) {
        collectionList.add(_sevenPlayer);
      }
    }

    if (_expansions.length > 0) {
      collectionList.add(_expansions);
    }

    if (_wishlist.length > 0) {
      collectionList.add(_wishlist);
    }

    if (_allOwnedItems.length > 0) {
      collectionList.add(_allOwnedItems);
    }

    if (_allRatedItems.length > 0) {
      collectionList.add(_allRatedItems);
    }

    if (_allItems.length > 0) {
      collectionList.add(_allItems);
    }

    return collectionList;
  }
}

class _CollectionSearchDelegate extends SearchDelegate {
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
      return _Collection(query);
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column();
  }
}