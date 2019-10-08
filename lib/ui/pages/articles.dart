import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:bgg_mobile/network/api.dart';
import 'package:bgg_mobile/models/article.dart';
import 'package:bgg_mobile/ui/helper.dart';
import 'package:bgg_mobile/models/helper.dart';
import 'package:bgg_mobile/ui/widgets/future_widget_builder.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticlesArguments {
  final String title;
  final bool showNext;
  final Function nextPressed;
  final String threadId;
  final String minArticleId;

  ArticlesArguments(this.title, this.threadId, this.minArticleId, [this.showNext, this.nextPressed]);
}

class Articles extends StatelessWidget {
  static const String routeName = '/articles';

  @override
  Widget build(BuildContext context) {
    final ArticlesArguments args = ModalRoute.of(context).settings.arguments;

    return new Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            args.title,
            minFontSize: 12,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          actions: (args.showNext != null && args.showNext) ? <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.navigate_next),
              onPressed: () {
                if (args.nextPressed != null) {
                  args.nextPressed();
                }
              },
            )
          ] : null,
        ),
        body: _ArticlesWidget(args.threadId, args.minArticleId)
    );
  }
}
class _ArticlesWidget extends StatefulWidget {
  final String threadId;
  final String minArticleId;

  _ArticlesWidget(this.threadId, this.minArticleId);

  @override
  createState() => new _ArticlesWidgetState();
}

class _ArticlesWidgetState extends State<_ArticlesWidget> {
  Future _future;

  @override
  Widget build(BuildContext context) {
    if (_future == null) {
      _future = Api.get().getArticles(widget.threadId, minArticleId: widget.minArticleId);
    }

    return FutureWidgetBuilder.buildView((context, obj) {
      return RefreshIndicator(
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
            color: Colors.black,
          ),
          itemCount: obj.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
              },
              child: _articleCell(obj[index]),
            );
          },
        ),
        onRefresh: _handleRefresh,
      );
    }, _future);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _future = Api.get().getArticles(widget.threadId);
    });
  }

  Widget _articleCell(Article article) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(article.username ?? '',
                  style: UIHelper.textStyle(weight: FontWeight.bold)
                ),
                flex: 1,
              ),
              Expanded(
                  child: Text(Helper.formatDateTime(article.postDate),
                      style: UIHelper.textStyle(weight: FontWeight.bold),
                      textAlign: TextAlign.right,
                  ),
                  flex: 2,
              ),
            ]
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child:  HtmlWidget(article.getBody(),
              textStyle: UIHelper.textStyle(),
              bodyPadding: EdgeInsets.all(0),
              onTapUrl: ((url) async {
                if (url == 'http://spoiler.com') {
                  article.toggleSpoilers();
                  setState(() {});
                  return;
                }
                else if (await canLaunch(url)) {
                  await launch(url);
                }
              }),
            ),
         ),
        ]),
    );
  }
}
