import 'package:bgg_mobile/models/helper.dart';

class Forum {
  String description;
  String groupId;
  String id;
  DateTime lastPostDate;
  bool noPosting;
  int numPosts;
  int numThreads;
  String title;

  Forum.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    groupId = json['groupid'];
    id = json['id'];
    lastPostDate = Helper.getDateTime(json, 'lastpostdate');
    noPosting = json['noposting'] == '1';
    numPosts = Helper.getInt(json, 'numposts');
    numThreads = Helper.getInt(json, 'numthreads');
    title = json['title'];
  }
}
