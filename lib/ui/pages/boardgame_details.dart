import 'package:auto_size_text/auto_size_text.dart';
import 'package:bgg_mobile/ui/routes.dart';
import 'package:bgg_mobile/ui/widgets/future_widget_builder.dart';
import 'package:flutter/material.dart';
import 'package:bgg_mobile/network/api.dart';
import 'package:bgg_mobile/models/boardgame.dart';
import 'package:bgg_mobile/models/link.dart';
import 'package:bgg_mobile/ui/helper.dart';
import 'package:bgg_mobile/ui/pages/forums.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class BoardgameDetailsArguments {
  final Boardgame game;

  BoardgameDetailsArguments(this.game);
}

class BoardgameDetails extends StatelessWidget {
  static const String routeName = '/boardgame_details';

  @override
  Widget build(BuildContext context) {
    BoardgameDetailsArguments args = ModalRoute
        .of(context)
        .settings
        .arguments;

    return new Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          args.game.name + (args.game.yearPublished != null ? " (" +
              args.game.yearPublished.toString() + ")" : ""),
          minFontSize: 12,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: _BoardgameDetailsWidget(args.game),
      ),
      backgroundColor: Colors.grey[300],
    );
  }
}

class _BoardgameDetailsWidget extends StatefulWidget {
  final Boardgame game;

  _BoardgameDetailsWidget(this.game);

  @override
  createState() => new _BoardgameDetailsWidgetState();
}

class _BoardgameDetailsWidgetState extends State<_BoardgameDetailsWidget> {
  Future _future;

  @override
  Widget build(BuildContext context) {
    if (_future == null) {
      _future = Api.get().getBoardgameDetails(widget.game.id);
    }

    return FutureWidgetBuilder.buildView((context, obj) {
      Boardgame game = obj;
      return Column(
          children: [
            Container(
              constraints: BoxConstraints.expand(height: 200.0),
              decoration: BoxDecoration(color: Colors.black),
              child: Image.network(game.image ?? game.thumbnail ?? "",
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null)
                    return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                          : null,
                    ),
                  );
                },
              ),
            ),
            Column(
              children: [
                _createTextGrid(_numPlayerRange(game), _playTimeRange(game)),
                Divider(
                  color: Colors.white,
                  height: 1,
                ),
                _createTextGrid('Age: ' + game.minAge.toString() + '+', 'Weight: ' + game.averageWeight.toStringAsFixed(2) + ' / 5'),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
                  child: Column(
                    children:[
                      _createTextRowFromLinks('Designer', game.designers),
                      _createTextRowFromLinks('Artist', game.artists),
                      _createTextRowFromLinks('Publisher', game.publishers),
                      _createTextColumnFromLinks('Category', game.categories),
                      _createTextColumnFromLinks('Mechanism', game.mechanics),
                      _createTextColumnFromLinks('Family', game.families),
                      _createTextColumnFromLinks('Expansion', game.expansions),
                      _createTextColumnFromLinks('Implementation', game.implementations),
                      _createDescription(game.description),
                      RaisedButton(
                        child: Text('Forums',
                          style: UIHelper.textStyle(),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.forums,
                            arguments: ForumsArguments(game.name, game),
                          );
                        },
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            )
          ]
      );
    }, _future);
  }

  Widget _createTextGrid(String left, String right) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            textAlign: TextAlign.center,
            style: UIHelper.textStyle(weight: FontWeight.bold),
          ),
        ),
        Container(
          height: 60,
          child: VerticalDivider(color: Colors.white),
        ),
        Expanded(
          child: Text(
            right,
            textAlign: TextAlign.center,
            style: UIHelper.textStyle(weight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _createTextRowFromLinks(String title, List<Link> links)
  {
    if (links == null || links.length == 0) {
      return Container();
    }

    var linkString = StringBuffer();
    bool first = true;

    links.forEach((item) {
      if (!first) {
        linkString.write(', ');
      }

      first = false;

      linkString.write(item.value);
    });

    return Padding(
      padding: EdgeInsets.only(top:5.0, bottom:5.0),
      child: RichText(
        text: new TextSpan(
          style: UIHelper.textStyle(),
          children: <TextSpan>[
            new TextSpan(text: title + ': ', style: new TextStyle(fontWeight: FontWeight.bold)),
            new TextSpan(text: linkString.toString()),
          ],
        ),
      ),
    );
  }

  Widget _createTextColumnFromLinks(String title, List<Link> links)
  {
    if (links == null || links.length == 0) {
      return Container();
    }

    List<Widget> children = new List();
    children.add(Text(title,
      style: UIHelper.textStyle(weight: FontWeight.bold),
    ));

    links.forEach((item) {
      children.add(Text(item.value,
        style: UIHelper.textStyle(),
      ));
    });

    return Padding(
      padding: EdgeInsets.only(top:5.0, bottom:5.0),
      child: Column(
        children: children,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }

  Widget _createDescription(String description)
  {
    if (description == null || description.length == 0) {
      return Container();
    }

    description = description
        .replaceAll('\\&#10;', '<br>')
        .replaceAll('\\', '');

    while (description.endsWith('<br>')) {
      description = _replaceLast(description, '<br>', '');
    }

    return Padding(
      padding: EdgeInsets.only(top:5.0, bottom:5.0),
      child: Column(
        children: [
          Text("Description",
            style: UIHelper.textStyle(weight: FontWeight.bold),
          ),
          HtmlWidget(description,
            textStyle: UIHelper.textStyle(),
            bodyPadding: EdgeInsets.all(0),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }

  String _replaceLast(String string, String substring, String replacement)
  {
    int index = string.lastIndexOf(substring);
    if (index == -1)
      return string;
    return string.substring(0, index) + replacement
        + string.substring(index+substring.length);
  }

  String _numPlayerRange(Boardgame game) {
    String range;
    bool singular = false;

    if (game.minPlayers == null && game.maxPlayers == null) {
      range = 'Unknown';
    }
    else if (game.maxPlayers == null) {
      range = game.minPlayers.toString();
    }
    else if (game.minPlayers == null) {
      range = game.maxPlayers.toString();
    }
    else if (game.minPlayers == game.maxPlayers) {
      range = game.minPlayers.toString();
      if (game.minPlayers == 1) {
        singular = true;
      }
    }
    else {
      range = game.minPlayers.toString() + "-" + game.maxPlayers.toString();
    }

    return range + ' player' + (singular?'':'s');
  }

  String _playTimeRange(Boardgame game) {
    String range;
    bool singular = false;

    if (game.minPlayTime == null && game.maxPlayTime == null) {
      range = 'Unknown';
    }
    else if (game.maxPlayTime == null) {
      range = game.minPlayTime.toString();
    }
    else if (game.minPlayTime == null) {
      range = game.maxPlayTime.toString();
    }
    else if (game.minPlayTime == game.maxPlayTime) {
      range = game.minPlayTime.toString();
      if (game.minPlayTime == 1) {
        singular = true;
      }
    }
    else {
      range = game.minPlayTime.toString() + "-" + game.maxPlayTime.toString();
    }

    return range + ' min' + (singular?'':'s');
  }
}
