import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String hint;
  final Function onChanged;

  SearchBar(this.title, this.hint, this.onChanged);

  @override
  createState() => new SearchBarState();

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class SearchBarState extends State<SearchBar> {
  String _title;
  Widget _appBarTitle;
  Icon _searchIcon;

  @override
  Widget build(BuildContext context) {
    if (_appBarTitle == null) {
      _title = widget.title;
      _appBarTitle = Text(widget.title);
      _searchIcon = Icon(Icons.search);
    }

    return AppBar(
      title: _appBarTitle,
      actions: <Widget>[
        new IconButton(
          icon: _searchIcon,
          onPressed: _searchPressed,
        ),
      ],
    );
  }

  void _searchPressed() {
    if (this._searchIcon.icon == Icons.search) {
      _updateAppBar(true);
    } else {
      _updateAppBar(false);
    }
  }

  void _updateAppBar(bool startSearch, [String query]) {
    if (startSearch) {
      setState(() {
        _searchIcon = new Icon(Icons.close);
        _appBarTitle = new TextField(
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search), hintText: widget.hint),
          onSubmitted: (s) {
            _updateAppBar(false, (_title == s) ? null : s);
          },
          autofocus: true,
          textInputAction: TextInputAction.search,
        );
      });
    } else {
      setState(() {
        if (query != null) {
          _title = widget.onChanged(query);
        }

        _appBarTitle = Text(_title);
        _searchIcon = Icon(Icons.search);
      });
    }
  }
}
