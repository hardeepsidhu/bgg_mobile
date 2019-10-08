import 'package:bgg_mobile/models/helper.dart';
import 'package:bgg_mobile/models/link.dart';
import 'package:html/dom.dart';

enum Type {
  BOARDGAME,
  BOARDGAME_EXPANSION
}

class Boardgame {
  Type type;
  String id;
  String thumbnail;
  String name;
  int yearPublished;

  int rank;
  int hotRank;

  int familyRank;
  double familyRating;
  String familyRankString;

  double geekRating;
  double avgRating;
  int numVoters;

  String description;
  String image;
  int minPlayers;
  int maxPlayers;
  int minPlayTime;
  int maxPlayTime;
  int playingTime;
  int minAge;
  // Todo Set bestWithNumPlayers;
  double averageWeight;
  List<Link> categories = new List();
  List<Link> mechanics = new List();
  List<Link> families = new List();
  List<Link> expansions = new List();
  List<Link> implementations = new List();
  List<Link> designers = new List();
  List<Link> artists = new List();
  List<Link> publishers = new List();
  List<String> alternateNames = new List();

  int numOwned;

  Boardgame(this.id, this.name);

  Boardgame.fromHotJson(Map<String, dynamic> json) {
    id = json['id'];
    thumbnail = Helper.getStringValue(json, 'thumbnail');
    name = Helper.parseHtml(Helper.getStringValue(json, 'name'));
    yearPublished = Helper.getIntValue(json, 'yearpublished');
    rank = Helper.getInt(json, 'rank');
  }

  Boardgame.fromHtml(Element html) {
    var nameElement = html.querySelector("td.collection_objectname > div > a");
    if (nameElement != null) {
      name = Helper.parseHtml(nameElement.text);

      var uri = Uri.parse(nameElement.attributes['href']);
      for (var path in uri.pathSegments) {
        var id = int.tryParse(path);
        if (id != null) {
          this.id = id.toString();
          break;
        }
      }
    }

    var rankElement = html.querySelector("td.collection_rank > a");
    if (rankElement != null) {
      rank = int.parse(rankElement.attributes['name']);
    }

    var thumbnailElement = html.querySelector("td.collection_thumbnail > a > img");
    if (thumbnailElement != null) {
      thumbnail = thumbnailElement.attributes['src'];
    }

    var ratingsElements = html.querySelectorAll("td.collection_bggrating");
    if (ratingsElements != null && ratingsElements.length == 3) {
      var expr = new RegExp(r'[^0-9.]');

      var geek = ratingsElements[0].firstChild.toString().replaceAll(expr, '');
      if (geek != null && geek.length > 0) {
        geekRating = double.parse(geek);
      }

      var avg = ratingsElements[1].firstChild.toString().replaceAll(expr, '');
      if (avg != null && avg.length > 0) {
        avgRating = double.parse(avg);
      }

      var num = ratingsElements[2].firstChild.toString().replaceAll(expr, '');
      if (num != null && num.length > 0) {
        numVoters = int.parse(num);
      }
    }
  }

  Boardgame.fromCollectionJson(Map<String, dynamic> json) {
    id = json['objectid'];
    name = Helper.parseHtml(Helper.getTextValue(json, 'name'));
    thumbnail = Helper.getTextValue(json, 'thumbnail');

    var yearText = Helper.getTextValue(json, 'yearpublished');
    if (yearText != null) {
      yearPublished = int.parse(yearText);
    }

    if (json['subtype'] == 'boardgameexpansion') {
      type = Type.BOARDGAME_EXPANSION;
    }
    else {
      type = Type.BOARDGAME;
    }

    var stats = json['stats'];
    var rating = stats['rating'];
    var ratings = Helper.getList(rating['ranks']['rank']);

    for (var map in ratings) {
      var type = map['type'];

      if (type == 'subtype') {
        rank = Helper.getInt(map, 'value');
        geekRating = Helper.getDouble(map, 'bayesaverage');
      }
      else if (type == 'family') {
        familyRank = Helper.getInt(map, 'value');
        familyRating = Helper.getDouble(map, 'bayesaverage');
        familyRankString = map['friendlyname'];
      }
    }

    avgRating = Helper.getDoubleValue(rating, 'average');
    numVoters = Helper.getIntValue(rating, 'usersrated');
    
    minPlayers = Helper.getInt(stats, 'minplayers');
    maxPlayers = Helper.getInt(stats, 'maxplayers');
    numOwned = Helper.getInt(stats, 'numowned');
  }

  Boardgame.fromDetailsJson(Map<String, dynamic> json) {
    if (json['type'] == 'boardgameexpansion') {
      type = Type.BOARDGAME_EXPANSION;
    }
    else {
      type = Type.BOARDGAME;
    }

    id = json['id'];
    thumbnail = Helper.getTextValue(json, 'thumbnail');
    yearPublished = Helper.getIntValue(json, 'yearpublished');

    description = Helper.getTextValue(json, 'description');
    image = Helper.getTextValue(json, 'image');
    minPlayers = Helper.getIntValue(json, 'minplayers');
    maxPlayers = Helper.getIntValue(json, 'maxplayers');
    minPlayTime = Helper.getIntValue(json, 'minplaytime');
    maxPlayTime = Helper.getIntValue(json, 'maxplaytime');
    playingTime = Helper.getIntValue(json, 'playingtime');
    minAge = Helper.getIntValue(json, 'minage');

    var links = json['link'];
    for (var item in links) {
      Link link = Link.fromJson(item);
      if (link.type == 'boardgamecategory') {
        categories.add(link);
      }
      else if (link.type == 'boardgamemechanic') {
        mechanics.add(link);
      }
      else if (link.type == 'boardgamefamily') {
        families.add(link);
      }
      else if (link.type == 'boardgameexpansion') {
        expansions.add(link);
      }
      else if (link.type == 'boardgameimplementation') {
        implementations.add(link);
      }
      else if (link.type == 'boardgamedesigner') {
        designers.add(link);
      }
      else if (link.type == 'boardgameartist') {
        artists.add(link);
      }
      else if (link.type == 'boardgamepublisher') {
        publishers.add(link);
      }
    }

    var names = Helper.getList(json['name']);
    for (var n in names) {
      if (n['type'] == 'primary') {
        name = n['value'];
      }
      else {
        alternateNames.add(n['value']);
      }
    }

    var ratings = json['statistics']['ratings'];

    numOwned = Helper.getIntValue(ratings, 'owned');
    avgRating = Helper.getDoubleValue(ratings, 'average');
    averageWeight = Helper.getDoubleValue(ratings, 'averageweight');
  }
}
