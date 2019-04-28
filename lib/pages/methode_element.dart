
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MethodeElementScreen extends StatefulWidget {
  MethodeElementScreen({Key key, this.methode}) : super(key: key);
  dynamic methode;
  @override
  State createState() => new MethodeElementScreenState();
}

class MethodeElementScreenState extends State<MethodeElementScreen> {
  MethodeElementScreenState();
  bool isLoading = false;

  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add Chat',
        child: const Icon(MdiIcons.headphones),
      ),
      body: Center(
        child: Text(widget.methode['title']),
      )
    );
  }
}