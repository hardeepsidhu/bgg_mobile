import 'package:bgg_mobile/ui/routes.dart';
import 'package:bgg_mobile/ui/widgets/drawer.dart';
import 'package:bgg_mobile/ui/widgets/future_widget_builder.dart';
import 'package:flutter/material.dart';
import 'package:bgg_mobile/network/api.dart';
import 'package:bgg_mobile/models/forum.dart';
import 'package:bgg_mobile/ui/pages/threads.dart';
import 'package:bgg_mobile/ui/helper.dart';
import 'package:bgg_mobile/models/helper.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class ForumsArguments {
  final String title;
  final dynamic object;

  ForumsArguments(this.title, this.object);
}

class Forums extends StatelessWidget {
  static const String routeName = '/forums';

  @override
  Widget build(BuildContext context) {
    ForumsArguments args =  ModalRoute.of(context).settings.arguments;
    if (args == null) {
      args = ForumsArguments('Forums', null);
    }

    return new Scaffold(
        appBar: AppBar(
          title: Text(args.title),
        ),
        drawer: (args.object == null) ? AppDrawer() : null,
        body: _ForumsWidget(args.object));
  }
}

class _ForumsWidget extends StatefulWidget {
  final dynamic object;

  _ForumsWidget(this.object);

  @override
  createState() => new _ForumsWidgetState();
}

class _ForumsWidgetState extends State<_ForumsWidget> {
  Future _future;

  @override
  Widget build(BuildContext context) {
    if (_future == null) {
      _future = Api.get().getForums(widget.object);
    }

    return FutureWidgetBuilder.buildListViewSeparated((context, index, obj) {
      return FlatButton(
        onPressed: () {
          if (obj.numThreads > 0 && obj.numPosts > 0) {
            Navigator.pushNamed(
              context,
              Routes.threads,
              arguments: ThreadsArguments(obj),
            );
          }
        },
        child: Row(children:[Expanded(child:_forumCell(obj))]),
      );
    }, _future);
  }

  Widget _forumCell(Forum forum) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(forum.title, style: UIHelper.textStyle(weight: FontWeight.bold)),
          HtmlWidget(forum.description,
            textStyle:UIHelper.textStyle(size: 14.0, weight: FontWeight.w300),
            bodyPadding: EdgeInsets.all(0),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Threads: ' + forum.numThreads.toString(),
                      style: UIHelper.textStyle(size: 14.0),
                    ),
                  ),
                  Expanded(
                    child: Text('Posts: ' + forum.numPosts.toString(),
                        style: UIHelper.textStyle(size: 14.0)),
                  ),
                ],
              ),
              Text('Last Post: ' + Helper.formatDateTime(forum.lastPostDate),
                  style: UIHelper.textStyle(size: 14.0)),
            ]),
          ),
        ],
      ),
    );
  }
}
