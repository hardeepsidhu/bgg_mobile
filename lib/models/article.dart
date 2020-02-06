import 'package:bgg_mobile/models/helper.dart';
import 'package:xml/xml.dart';

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

  Article.fromXml(XmlElement xml) {
    for (var attr in xml.attributes) {
      var name = attr.name.qualified;
      var value = attr.value;

      switch (name) {
        case 'id':
          id = value;
          break;
        case 'username':
          username = value;
          break;
        case 'link':
          link = value;
          break;
        case 'postdate':
          postDate = Helper.getDateTimeFromString(value);
          break;
        case 'editdate':
          editDate = Helper.getDateTimeFromString(value);
          break;
        case 'numedits':
          numEdits = int.parse(value);
          break;
      }
    }

    subject = xml.findElements('subject')?.first?.text;
    body = xml.findElements('body')?.first?.text;

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
      return body.replaceAll(new RegExp(r'\[o\](.|\r|\n)*?\[\/o\]'),
          r'<a href=http://spoiler.com>*SPOILER*</a>');
    }
  }
}