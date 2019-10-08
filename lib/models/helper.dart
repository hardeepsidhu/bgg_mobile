import 'package:intl/intl.dart';

class Helper {
  static List getList(dynamic l) {
    if (l is List) {
      return l;
    }
    else {
      var list = new List();
      list.add(l);
      return list;
    }
  }

  static String getStringValue(Map<String, dynamic> json, String key) {
    if (json[key] != null && json[key]['value'] != null) {
      return json[key]['value'];
    }
    else {
      return null;
    }
  }

  static int getIntValue(Map<String, dynamic> json, String key) {
    String value = getStringValue(json, key);
    if (value != null) {
      return int.parse(value);
    }
    else {
      return 0;
    }
  }

  static double getDoubleValue(Map<String, dynamic> json, String key) {
    String value = getStringValue(json, key);
    if (value != null) {
      try {
        return double.parse(value);
      }
      catch (Exception) {
        return 0.0;
      }
    }
    else {
      return 0.0;
    }
  }

  static int getInt(Map<String, dynamic> json, String key) {
    if (json[key] != null) {
      try {
        return int.parse(json[key]);
      }
      catch (Exception) {
        return 0;
      }
    }
    else {
      return 0;
    }
  }

  static double getDouble(Map<String, dynamic> json, String key) {
    if (json[key] != null) {
      try {
        return double.parse(json[key]);
      }
      catch (Exception) {
        return 0;
      }
    }
    else {
      return 0;
    }
  }

  static String getTextValue(Map<String, dynamic> json, String key) {
    if (json[key] == null || json[key]['\$t'] == null) {
      return null;
    }

    String value = "";
    try {
      String cdata = json[key]['__cdata'];
      if (cdata != null) {
        value += cdata;
      }
    }
    catch(Exception) { }

    return value + json[key]['\$t'];
  }

  static String parseHtml(String html) {
    return html
        .replaceAll('\\&#10;', '<br>')
        .replaceAll('\\r', '')
        .replaceAll('\\', '');
  }

  static DateFormat _formatParse = new DateFormat('EEE, dd MMM yyyy HH:mm:ss Z');
  static DateFormat _formatToday = new DateFormat('h:mm a');
  static DateFormat _formatOlder = new DateFormat('EEE MMM d, yyyy h:mm a');


  static DateTime getDateTime(Map<String, dynamic> json, String key) {
    if (json[key] != null && json[key].length > 0) {
      try {
        return _formatParse.parse(json[key]);
      }
      catch (Exception) {
        try {
          return DateTime.parse(json[key]);
        }
        catch (Exception) {
          return null;
        }
      }
    }
    else {
      return null;
    }
  }

  static String formatDateTime(DateTime time) {
    if (time == null) {
      return 'Never';
    }

    DateTime today = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration twoDay = new Duration(days: 2);

    String date;

    Duration difference = today.difference(time);

    if (difference.compareTo(oneDay) < 1) {
      date = 'Today';
    }
    else if (difference.compareTo(twoDay) < 1) {
      date = 'Yesterday';
    }

    if (date != null) {
      date = date + ' ' + _formatToday.format(time);
    }
    else {
      date = _formatOlder.format(time);
    }

    return date;
  }
}
