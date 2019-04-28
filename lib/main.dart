import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gagasiney/pages/home_page.dart';
import 'package:flutter/cupertino.dart';

void main() async {

  Widget _defaultHome = new HomeScreen();

  Firestore firestore = Firestore.instance;
  firestore.settings(timestampsInSnapshotsEnabled: true);
  // Run app!
  runApp(MyApp(_defaultHome));
}

ThemeData theme = ThemeData(
  primaryColor: Colors.green,
  primarySwatch: Colors.green,
  backgroundColor: Colors.white10,
  fontFamily: 'PTSans',
);

class MyApp extends StatelessWidget {
  MyApp(this.defaultHome);
  final Widget defaultHome;
  // This widget is the root of the application.

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
    title: 'Hackathon',
    home: defaultHome,
    theme: theme,
    routes: <String, WidgetBuilder>{
      // Set routes for using the Navigator.
      '/home': (BuildContext context) => new HomeScreen(),
    },
  );
  }
}


