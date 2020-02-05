import 'package:bgg_mobile/models/link.dart';
import 'package:html/dom.dart';

class Subscription {
  Link thread;
  Link forum;
  Link article;
  Link boardgame;
  Link boardgameFamily;
  Link guild;
  Link geeklist;

  Subscription.fromHtml(Element html) {
    String threadId = html.attributes['id'];
    if (threadId != null) {
      thread = Link(id:threadId.replaceAll('GSUB_itemline_thread_', ''));
    }

    List<Element> refs = html.querySelectorAll('a');
    for (var ref in refs) {
      var href = ref.attributes['href'];
      if (href != null) {
        var tokens = href.split('/');
        if (tokens.length >= 3 && !tokens[0].contains('javascript')) {
          Link link = new Link(id:tokens[2], value:ref.text);

          switch (tokens[1]) {
            case "thread": {
              thread = link;

              if (tokens.length > 4 && tokens[3] == "article") {
                article = getArticle(tokens[4], ref.text);
              }

              break;
            }
            case "forum": {
              forum = link;
              break;
            }
            case "article": {
              article = getArticle(tokens[2], ref.text);
              break;
            }
            case "boardgame": {
              boardgame = link;
              break;
            }
            case "boardgamefamily": {
              boardgameFamily = link;
              break;
            }
            case "guild": {
              guild = link;
              break;
            }
            case "geeklist": {
              geeklist = link;
              break;
            }
          }
        }
      }
    }
  }

  Link getArticle(String token, String value) {
    Link link;

    var articles = token.split("#");
    if (articles.length > 0) {
      link = new Link(id: articles[0], value:value);
    }

    return link;
  }

  String getTitle() {
    if (article != null) {
      return article.value;
    }
    else {
      return thread.value;
    }
  }

  String getSubtitle() {
    List<String> list = new List();

    if (guild != null) {
      list.add(guild.value);
    }

    if (boardgameFamily != null) {
      list.add(boardgameFamily.value);
    }

    if (boardgame != null) {
      list.add(boardgame.value);
    }

    if (forum != null) {
      list.add(forum.value);
    }

    return list.join(' / ');
  }

  String getHeaderSubtitle() {
    if (boardgame != null) {
      return boardgame.value;
    }
    else if (boardgameFamily != null) {
      return boardgameFamily.value;
    }
    else if (guild != null) {
      return guild.value;
    }
    else if (forum != null) {
      return forum.value;
    }
    else {
      return '';
    }
  }

  String getMinArticleId() {
    if (article != null) {
      return article.id;
    }
    else {
      return '0';
    }
  }
}
