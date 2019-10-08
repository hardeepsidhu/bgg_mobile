import 'package:bgg_mobile/models/boardgame.dart';
import 'package:bgg_mobile/models/helper.dart';

class CollectionItem {
  Boardgame game;

  bool owned;
  bool wishlist;
  bool forTrade;
  bool prevOwned;
  bool preordered;
  bool want;
  bool wantToBuy;
  bool wantToPlay;
  int wishlistPriority;
  double rating;
  int numPlays;

  CollectionItem.fromJson(Map<String, dynamic> json) {
    game = Boardgame.fromCollectionJson(json);

    var status = json['status'];
    for (var key in status.keys) {
      var value = status[key];
      switch (key) {
        case 'own':
          owned = (value == '1');
          break;
        case 'wishlist':
          wishlist = (value == '1');
          break;
        case 'fortrade':
          forTrade = (value == '1');
          break;
        case 'prevowned':
          prevOwned = (value == '1');
          break;
        case 'preordered':
          preordered = (value == '1');
          break;
        case 'want':
          want = (value == '1');
          break;
        case 'wanttobuy':
          wantToBuy = (value == '1');
          break;
        case 'wanttoplay':
          wantToPlay = (value == '1');
          break;
        case 'wishlistpriority':
          wishlistPriority = int.parse(value);
          break;
      }
    }

    rating = Helper.getDoubleValue(json['stats'], 'rating');

    if (json['numplays'] != null) {
      numPlays = int.parse(Helper.getTextValue(json, 'numplays'));
    }
  }
}