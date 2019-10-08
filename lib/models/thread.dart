import 'package:bgg_mobile/models/helper.dart';

class Thread {
  String author;
  String id;
  DateTime lastPostDate;
  int numArticles;
  DateTime postDate;
  String subject;

  Thread.fromJson(Map<String, dynamic> json) {
    author = json['author'];
    id = json['id'];
    lastPostDate = Helper.getDateTime(json, 'lastpostdate');
    numArticles = Helper.getInt(json, 'numarticles');
    postDate = Helper.getDateTime(json, 'postdate');
    subject = json['subject'];
  }
}