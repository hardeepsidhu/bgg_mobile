import 'package:bgg_mobile/models/collection_item.dart';
import 'package:bgg_mobile/ui/routes.dart';
import 'package:flutter/material.dart';
import 'package:bgg_mobile/ui/widgets/boardgame_cell.dart';
import 'package:bgg_mobile/ui/pages/boardgame_details.dart';

class CollectionListArguments {
  final String title;
  final List<CollectionItem> list;

  CollectionListArguments(this.title, this.list);

}
class CollectionList extends StatelessWidget {
  static const String routeName = '/collection_list';

  @override
  Widget build(BuildContext context) {
    final CollectionListArguments args = ModalRoute.of(context).settings.arguments;

    return new Scaffold(
        appBar: AppBar(
          title: Text(args.title),
        ),
        body: _CollectionListWidget(args.list),
    );
  }
}

class _CollectionListWidget extends StatefulWidget {
  final List<CollectionItem> list;

  _CollectionListWidget(this.list);
  @override
  createState() => new _CollectionListWidgetState();
}

class _CollectionListWidgetState extends State<_CollectionListWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.list.length,
      itemBuilder: (context, index) {
        var obj = widget.list[index];
        return new FlatButton(
          child: new BoardgameCell(obj.game,
              rating: obj.rating > 0.0 ? obj.rating : null),
          padding: const EdgeInsets.all(0.0),
          color: Colors.white,
          onPressed: () {
            Navigator.pushNamed(
              context,
              Routes.boardgame_details,
              arguments: BoardgameDetailsArguments(obj.game),
            );
          },
        );
      },
    );
  }
}
