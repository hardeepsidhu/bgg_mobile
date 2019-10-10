import 'package:bgg_mobile/models/subscription.dart';
import 'package:bgg_mobile/network/api.dart';
import 'package:bgg_mobile/settings/settings.dart';
import 'package:bgg_mobile/ui/pages/articles.dart';
import 'package:bgg_mobile/ui/helper.dart';
import 'package:bgg_mobile/ui/routes.dart';
import 'package:bgg_mobile/ui/widgets/drawer.dart';
import 'package:bgg_mobile/ui/widgets/future_widget_builder.dart';
import 'package:flutter/material.dart';

class SubscriptionsPage extends StatelessWidget {
  static const String routeName = '/subscriptions_page';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text('Subscriptions'),
        ),
        drawer: AppDrawer(),
        body: _SubscriptionsWidget());
  }
}

class _SubscriptionsWidget extends StatefulWidget {
  @override
  createState() => new _SubscriptionsWidgetState();
}

class _SubscriptionsWidgetState extends State<_SubscriptionsWidget> {
  Future _future;
  List<Subscription> _subscriptions = new List();
  List<Subscription> _oldSubscriptions = new List();

  @override
  Widget build(BuildContext context) {
    if (_future == null) {
      _future = getSubscriptions();
    }

    return FutureWidgetBuilder.buildView((context, obj) {
      return RefreshIndicator(
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
            color: Colors.black,
          ),
          itemCount: _subscriptions.length + _oldSubscriptions.length,
          itemBuilder: (context, index) {
            Subscription sub;
            if (index < _subscriptions.length) {
              sub = _subscriptions[index];
            } else {
              sub = _oldSubscriptions[index - _subscriptions.length];
            }

            return FlatButton(
              onPressed: () {
                _launchSubscription(context, sub);
              },
              child: Row(
                children: [Expanded(child: _subscriptionCell(sub))],
              ),
            );
          },
        ),
        onRefresh: _handleRefresh,
      );
    }, _future);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _future = getSubscriptions();
    });
  }

  void _launchSubscription(BuildContext context, Subscription subscription,
      {bool replace}) async {
    var arguments = ArticlesArguments(subscription.getTitle(),
        subscription.thread.id, subscription.getMinArticleId(), true, () {
      if (_subscriptions.length > 0) {
        _launchSubscription(context, _subscriptions.first, replace: true);
      } else {
        Navigator.pop(context);
        _handleRefresh();
      }
    });

    if (replace == null || !replace) {
      Navigator.pushNamed(context, Routes.articles, arguments: arguments);
    } else {
      Navigator.pushReplacementNamed(context, Routes.articles,
          arguments: arguments);
    }

    Api.get().markThreadAsRead(subscription.thread.id);
    if (_subscriptions.contains(subscription)) {
      setState(() {
        _subscriptions.remove(subscription);
        _oldSubscriptions.add(subscription);
      });
    }
  }

  Future<List<Subscription>> getSubscriptions() async {
    await Api.get().login(Settings.get().username, Settings.get().password);
    _subscriptions = await Api.get().getSubscriptions();
    return _subscriptions;
  }

  Widget _subscriptionCell(Subscription subscription) {
    bool read = _oldSubscriptions.contains(subscription);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subscription.getTitle(),
              style: UIHelper.textStyle(
                  weight: read ? FontWeight.w200 : FontWeight.bold)),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_getSubscriptions(subscription),
                  style: UIHelper.textStyle(
                      size: 14.0,
                      weight: read ? FontWeight.w200 : FontWeight.normal)),
            ]),
          ),
        ],
      ),
    );
  }

  String _getSubscriptions(Subscription subscription) {
    List<String> subscriptions = new List();

    if (subscription.forum != null) {
      subscriptions.add("Forum: " + subscription.forum.value);
    }

    if (subscription.boardgame != null) {
      subscriptions.add("Boardgame: " + subscription.boardgame.value);
    }

    if (subscription.boardgameFamily != null) {
      subscriptions.add("Family: " + subscription.boardgameFamily.value);
    }

    if (subscription.guild != null) {
      subscriptions.add("Guild: " + subscription.guild.value);
    }

    return subscriptions.join('\n');
  }
}
