import 'package:flutter/material.dart';

class FutureWidgetBuilder {
  static Widget buildListView(Widget Function(dynamic context, int index, dynamic obj) createWidget, Future future) {
    return _buildFutureBuilder((context, snapshot) {
      return ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (context, index) {
          var obj = snapshot.data[index];
          return createWidget(context, index, obj);
        },
      );
    }, future);
  }

  static Widget buildListViewSeparated(Widget Function(dynamic context, int index, dynamic obj) createWidget, Future future) {
    return _buildFutureBuilder((context, snapshot) {
      return ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Colors.black,
        ),
        itemCount: snapshot.data.length,
        itemBuilder: (context, index) {
          var obj = snapshot.data[index];
          return createWidget(context, index, obj);
        },
      );
    }, future);
  }

  static Widget buildView(Widget Function(dynamic context, dynamic obj) createWidget, Future future) {
    return _buildFutureBuilder((context, snapshot) {
      return createWidget(context, snapshot.data);
    }, future);
  }

  static Widget _buildFutureBuilder(Widget Function(dynamic context, dynamic snapshot) createWidget, Future future) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          else {
            return createWidget(context, snapshot);
          }
        }
        else {
          return new Center(
            child: new CircularProgressIndicator(),
          );
        }
      },
      future: future,
    );
  }
}