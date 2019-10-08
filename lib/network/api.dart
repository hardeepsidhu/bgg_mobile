import 'dart:convert';
import 'package:bgg_mobile/models/collection_item.dart';
import 'package:bgg_mobile/models/subscription.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:xml2json/xml2json.dart';
import 'package:bgg_mobile/models/article.dart';
import 'package:bgg_mobile/models/boardgame.dart';
import 'package:bgg_mobile/models/forum.dart';
import 'package:bgg_mobile/models/helper.dart';
import 'package:bgg_mobile/models/thread.dart';

class Api {
  static final Api _api = new Api._internal();

  static Api get() {
    return _api;
  }

  Api._internal();

  Future<Response> login(String username, String password) async {
    var parameters = {
      'username': username,
      'password': password,
    };

    return _doPost('/login', parameters: parameters);
  }

  Future<Response> getTop100() async {
    var parameters = {
      'ajax': '1',
    };

    return _doGet('/browse/boardgame/page/1', parameters);
  }

  Future<List<Boardgame>> getHot() async {
    var parameters = {
      'type': 'boardgame',
    };

    var response = await _doGet('/xmlapi2/hot', parameters);
    return _getJsonList(response, ['items', 'item'], ((obj) {
      return Boardgame.fromHotJson(obj);
    }));
  }

  Future<List<Boardgame>> search(String query) async {
    var parameters = {
      'q': query,
    };

    var response = await _doGet('/search/boardgame/page/1', parameters);
    var document = parse(response.body);

    List<Boardgame> list = new List();
    List<Element> rows = document.querySelectorAll("#row_");

    for (var row in rows) {
      list.add(Boardgame.fromHtml(row));
    }

    return list;
  }

  Future<Response> searchApi(String query) async {
    var parameters = {
      'query': query,
      'type': 'boardgame',
    };

    return _doGet('/xmlapi2/search', parameters);
  }

  Future<List<CollectionItem>> getCollection(String username, bool getAll) async {
    Map<String, String> parameters;

    if (getAll) {
      parameters = {
        'username': username,
        'subtype': 'boardgame',
        'stats': '1',
      };
    }
    else {
      parameters = {
        'username': username,
        'subtype': 'boardgame',
        'excludesubtype': 'boardgameexpansion',
        'stats': '1',
      };
    }

    var response = await _doGet('/xmlapi2/collection', parameters);
    while (response.statusCode == 202) {
      await Future.delayed(Duration(seconds: 5));
      response = await _doGet('/xmlapi2/collection', parameters);
    }

    return _getJsonList(response, ['items', 'item'], ((obj) {
      return CollectionItem.fromJson(obj);
    }));
  }

  Future<Boardgame> getBoardgameDetails(String id) async {
    var parameters = {
      'id': id,
      'versions': '0',
      'stats': '1',
    };

    var response = await _doGet('/xmlapi2/thing', parameters);
    var list = _getJsonList(response, ['items', 'item'], ((obj) {
      return Boardgame.fromDetailsJson(obj);
    }));

    return list.first;
  }

  Future<Response> getUserInformation(String username) async {
    var parameters = {
      'name': username,
      'buddies': '1',
      'guilds': '1',
      'hot': '1',
      'top': '1',
    };

    return _doGet('/xmlapi2/user', parameters);
  }

  Future<Response> getPlays(String username, String page) async {
    var parameters = {
      'username': username,
      'page': page,
    };

    return _doGet('/xmlapi2/plays', parameters);
  }

  Future<Response> getFamily(String id) async {
    var parameters = {
      'id': id,
      'type': 'boardgamefamily',
    };

    return _doGet('/xmlapi2/family', parameters);
  }

  Future<List<Forum>> getForums(dynamic obj) async {
    if (obj is Boardgame) {
      return _getForums(obj.id, 'thing');
    }
    else {
      return _getForums('1', 'region');
    }
  }

  Future<List<Forum>> _getForums(String id, String type) async {
    var parameters = {
      'id': id,
      'type': type,
    };

    var response = await _doGet('/xmlapi2/forumlist', parameters);
    return _getJsonList(response, ['forums', 'forum'], ((obj) {
      return Forum.fromJson(obj);
    }));
  }

  Future<List<Thread>> getThreads(String id, String page) async {
    var parameters = {
      'id': id,
      'page': page,
    };

    var response = await _doGet('/xmlapi2/forum', parameters);
    return _getJsonList(response, ['forum', 'threads', 'thread'], ((obj) {
      return Thread.fromJson(obj);
    }));
  }

  Future<List<Article>> getArticles(String id, {String minArticleId = '1'}) async {
    var parameters = {
      'id': id,
      'minarticleid': minArticleId,
    };

    var response = await _doGet('/xmlapi2/thread', parameters);
    return _getJsonList(response, ['thread', 'articles', 'article'], ((obj) {
      return Article.fromJson(obj);
    }));
  }

  Future<Response> getGeeklist(String id) async {
    var parameters = {
      'comments': '1',
    };

    return _doGet('/xmlapi/geeklist/'+id, parameters);
  }

  Future<List<Subscription>> getSubscriptions() async {
    var parameters = {
      'ajax': '1',
    };

    var response = await _doGet('subscriptions', parameters, setCookieHeader: true);
    var document = parse(response.body);

    List<Subscription> list = new List();

    List<Element> rows = document.querySelectorAll("tr[id^=GSUB_itemline_thread]");

    for (var row in rows) {
      list.add(Subscription.fromHtml(row));
    }

    return list;
  }

  Future<Response> markThreadAsRead(String id) async {
    var body = {
      'instanceid': '1',
      'loadmodule': '1',
      'sort': '',
      'sortdir': 'desc',
      'pageid': '1',
      'moduletype': 'groupobject',
      'ottype': 'groupobject',
      'viewfilter': 'new',
      'objecttype': 'thread',
      'objectid': id,
      'action': 'markallread',
      'ajax': '1',
    };

    var response = await _doPost('/geekviews.php', body: body, setCookieHeader: true);
    return response;
  }

  static const String _bggUrl = "boardgamegeek.com";

  final Client _client = new Client();
  final Xml2Json xmlTransformer = Xml2Json();

  Map<String, String> _cookieHeader = {};
  Map<String, String> cookies = {};

  Future<Response> _doGet(String path, Map<String, String> parameters, {bool setCookieHeader}) async {
    var uri = Uri.https(_bggUrl, path, parameters);

    Response response;

    if (setCookieHeader == null) {
      response = await _client.get(uri);
    }
    else {
      response = await _client.get(uri, headers: _cookieHeader);
    }

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      if (setCookieHeader != null) {
        _updateCookies(response);
      }

      return response;
    }
    else {
      throw ("GET Request: " + uri.toString() + " failed with status code: "+ response.statusCode.toString());
    }
  }

  Future<Response> _doPost(String path, {Map<String, String> parameters, Map<String, String> body, bool setCookieHeader}) async {
    var uri = Uri.https(_bggUrl, path, parameters);

    Response response;
    if (setCookieHeader != null && setCookieHeader) {
      response = await _client.post(uri, body: body, headers:_cookieHeader);
    }
    else {
      response = await _client.post(uri, body: body);
    }

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      _updateCookies(response);
      return response;
    }
    else {
      throw ("POST Request: " + uri.toString() + " failed with status code: "+ response.statusCode.toString());
    }
  }

  List<T> _getJsonList<T>(Response response, List<String> keys, T Function(dynamic item) createObject) {
    dynamic jsonList = _getJsonData(response);

    keys.forEach((key) {
      jsonList = jsonList[key];
    });

    jsonList = Helper.getList(jsonList);

    List<T> list = new List();
    for (var item in jsonList) {
      T obj = createObject(item);
      list.add(obj);
    }

    return list;
  }

  dynamic _getJsonData(Response response) {
    var body = response.body.replaceAll('&quot;', '\'')
        .replaceAll(RegExp(r"(?<!\\)\\(?!\\)"), '\\\\');

    xmlTransformer.parse(body);
    var jsonString = xmlTransformer.toGData();
    return json.decode(jsonString);
  }

  void _updateCookies(Response response) {
    String allSetCookie = response.headers['set-cookie'];

    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');

      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');

        for (var cookie in cookies) {
          _setCookie(cookie);
        }
      }

      _cookieHeader['cookie'] = _generateCookieHeader();
    }
  }

  void _setCookie(String rawCookie) {
    if (rawCookie.length > 0) {
      var keyValue = rawCookie.split('=');
      if (keyValue.length == 2) {
        var key = keyValue[0].trim();
        var value = keyValue[1];

        // ignore keys that aren't cookies
        if (key == 'path' || key == 'expires')
          return;

        this.cookies[key] = value;
      }
    }
  }

  String _generateCookieHeader() {
    String cookie = "";

    for (var key in cookies.keys) {
      if (cookie.length > 0)
        cookie += ";";
      cookie += key + "=" + cookies[key];
    }

    return cookie;
  }
}
