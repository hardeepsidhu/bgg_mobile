import 'package:bgg_mobile/ui/routes.dart';
import 'package:bgg_mobile/ui/widgets/future_widget_builder.dart';
import 'package:flutter/material.dart';
import 'package:bgg_mobile/network/api.dart';
import 'package:bgg_mobile/models/forum.dart';
import 'package:bgg_mobile/models/thread.dart';
import 'package:bgg_mobile/ui/pages/articles.dart';
import 'package:bgg_mobile/ui/helper.dart';
import 'package:bgg_mobile/models/helper.dart';

class ThreadsArguments {
  final Forum forum;

  ThreadsArguments(this.forum);
}

class Threads extends StatelessWidget {
  static const String routeName = '/threads';

  @override
  Widget build(BuildContext context) {
    ThreadsArguments args = ModalRoute
        .of(context)
        .settings
        .arguments;

    return new Scaffold(
        appBar: AppBar(
          title: Text(args.forum.title),
        ),
        body: _ThreadsWidget(args.forum));
  }
}

class _ThreadsWidget extends StatefulWidget {
  final Forum forum;

  _ThreadsWidget(this.forum);

  @override
  createState() => new _ThreadsWidgetState();
}

class _ThreadsWidgetState extends State<_ThreadsWidget> {
  Future _future;

  @override
  Widget build(BuildContext context) {
    if (_future == null) {
      _future = Api.get().getThreads(widget.forum.id, '1');
    }

    return FutureWidgetBuilder.buildListViewSeparated((context, index, obj) {
      return FlatButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.articles,
              arguments: ArticlesArguments(obj.subject, null, obj.id, '1'));
        },
        child: Row(
          children: [Expanded(child: _threadCell(obj))],
        ),
      );
    }, _future);
  }

  Widget _threadCell(Thread thread) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(thread.subject,
              style: UIHelper.textStyle(weight: FontWeight.bold)),
          Text(
            'by ' +
                thread.author +
                ' ' +
                Helper.formatDateTime(thread.postDate),
            style: UIHelper.textStyle(size: 14.0, weight: FontWeight.w300),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Replies: ' + thread.numArticles.toString(),
                  style: UIHelper.textStyle(size: 14.0)),
              Text('Last Post: ' + Helper.formatDateTime(thread.lastPostDate),
                  style: UIHelper.textStyle(size: 14.0)),
            ]),
          ),
        ],
      ),
    );
  }
}
