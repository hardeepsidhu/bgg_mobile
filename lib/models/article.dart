import 'package:bgg_mobile/models/helper.dart';

class Article {
  DateTime editDate;
  String id;
  String link;
  int numEdits;
  DateTime postDate;
  String username;
  String body;
  String subject;
  bool showSpoilers;

  Article.fromJson(Map<String, dynamic> json) {
    editDate = Helper.getDateTime(json, 'editdate');
    id = json['id'];
    link = json['link'];
    numEdits = Helper.getInt(json, 'numedits');
    postDate = Helper.getDateTime(json, 'postdate');
    username = json['username'];
    body = Helper.parseHtml(Helper.getTextValue(json, 'body'));
    subject = Helper.getTextValue(json, 'subject');
    showSpoilers = false;
  }

  void toggleSpoilers() {
    showSpoilers = !showSpoilers;
  }

  String getBody() {
    if (showSpoilers) {
      return body.replaceAll(new RegExp(r'\[o\]'), '')
          .replaceAll(new RegExp(r'\[\/o\]'), '');
    }
    else {
      return body.replaceAll(new RegExp(r'\[o\].*\[\/o\]'),
          r'<a href=http://spoiler.com>*SPOILER*</a>');
    }
  }
}