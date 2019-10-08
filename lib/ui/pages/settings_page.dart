import 'package:bgg_mobile/ui/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:bgg_mobile/settings/settings.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings_page';

  @override
  State<StatefulWidget> createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();

  _SettingsPageState() {
    _usernameController.addListener(_usernameListen);
    _passwordController.addListener(_passwordListen);
  }

  void _usernameListen() {
    if (_usernameController.text.isEmpty) {
      Settings.get().username = "";
    } else {
      Settings.get().username = _usernameController.text;
    }
  }

  void _passwordListen() {
    if (_passwordController.text.isEmpty) {
      Settings.get().password = "";
    } else {
      Settings.get().password = _passwordController.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      drawer: AppDrawer(),
      body: new Container(
        padding: EdgeInsets.all(16.0),
        child: new Column(
          children: <Widget>[
            _buildTextFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFields() {
    _usernameController.text = Settings.get().username;
    _passwordController.text = Settings.get().password;

    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            child: new TextField(
              controller: _usernameController,
              decoration: new InputDecoration(
                  labelText: 'Username'
              ),
            ),
          ),
          new Container(
            child: new TextField(
              controller: _passwordController,
              decoration: new InputDecoration(
                  labelText: 'Password'
              ),
              obscureText: true,
            ),
          )
        ],
      ),
    );
  }
}