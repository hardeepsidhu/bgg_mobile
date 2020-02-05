import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Settings {
  static final Settings _settings = new Settings();

  String _username = '';
  String _password = '';
  Map<String, List> _allCollectionMap = new Map();
  Map<String, List> _gamesCollectionMap = new Map();

  final _storage = new FlutterSecureStorage();

  static Settings get() {
    return _settings;
  }

  String get username => _username;

  set username(String username) {
    _username = username;
    _storage.write(key: 'username', value: _username);
  }

  String get password => _password;

  set password(String password) {
    _password = password;
    _storage.write(key: 'password', value: _password);
  }

  List getAllCollection(String username) {
    return _allCollectionMap[username];
  }

  List getGamesCollection(String username) {
    return _gamesCollectionMap[username];
  }

  void setCollection(String username, List allCollection, List gamesCollection) {
    _allCollectionMap[username] = allCollection;
    _gamesCollectionMap[username] = gamesCollection;
  }

  Future<void> load() async {
    _username = (await _storage.read(key: 'username')) ?? '';
    _password = (await _storage.read(key: 'password')) ?? '';
  }
}
