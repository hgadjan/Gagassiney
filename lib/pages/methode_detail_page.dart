import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:gagasiney/models/models.dart';
import 'package:gagasiney/utils/utils.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:path_provider/path_provider.dart';

enum PlayerState { playing, paused, stopped }

class MethodeDetailScreen extends StatefulWidget {
  MethodeDetailScreen({Key key, this.methode}) : super(key: key);
  Methode methode;

  @override
  State createState() => new MethodeDetailScreenState();
}

class MethodeDetailScreenState extends State<MethodeDetailScreen> 
  with SingleTickerProviderStateMixin {

  MethodeDetailScreenState();
  bool isLoading = false;
  TabBar tabs;
  List<String> _SECTIONS = ["Presentation", "Avantage", "Inconvenient", 'Ou Trouver'];

  TabController _tabController;

  @override
  void initState() { 
    super.initState();

    _tabController = new TabController(vsync: this, initialIndex: 0, length: 4);
  }

  Widget sliders(){
    return Container(
    child: new SizedBox(
      height: 200.0,
      child: 
      new StreamBuilder(
        stream: Firestore.instance.collection('gagasiney/app/sliders').where('id_methode', isEqualTo: widget.methode.id).snapshots(),
        builder: (context, snapshot) {
          var screenWidth = MediaQuery.of(context).size.width;
          if (!snapshot.hasData) {
            return 
            Image.asset(
              'images/img_not_available.jpeg',
              width: screenWidth,
              height: 200.0,
              fit: BoxFit.cover,
            );
          } else {
            var imgs = [];
            for (var slide in snapshot.data.documents) {
              imgs.add(
                CachedNetworkImage(
                  placeholder: Container(
                    child: Center(
                      child:  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                    ),
                    padding: EdgeInsets.all(70.0),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                  ),
                  errorWidget: Material(
                    child: Image.asset(
                      'images/img_not_available.jpeg',
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  imageUrl: slide['url'],
                  fit: BoxFit.cover,
                )
              );
            }
            return new Swiper(
              // viewportFraction: 0.8,
              // scale: 0.9,
              itemBuilder: (BuildContext context, int index){
                return imgs[index];
              },
              itemCount: imgs.length,
              autoplay: true,
              pagination: new SwiperPagination(),
              control: new SwiperControl(),
            );
          }
        },
      ),
    ),
  );
  }
  
  @override
  Widget build(BuildContext context) {
    
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            child: SliverAppBar(
              pinned: true,
              titleSpacing: 0,
              expandedHeight: 300,
              title: ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text(widget.methode.title, style: TextStyle(color: Colors.white, fontSize: 17),),
                subtitle: Text('Methodes contraceptives', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.greenAccent,
                  foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black87,
                        Colors.transparent,
                        Colors.black87,
                      ]
                    )
                  ),
                  child: sliders(),
                ),
              ),
              forceElevated: innerBoxIsScrolled,
              bottom: TabBar(
                isScrollable: true,
                controller: _tabController,
                indicator: UnderlineTabIndicator(insets: EdgeInsets.only(bottom: 1)),
                tabs: _SECTIONS.map((title) => Tab(child: Text(title))).toList()
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                  },
                  icon: Icon(Icons.call),
                ),
                IconButton(
                  onPressed: () {
                  },
                  icon: Icon(Icons.location_searching),
                )
              ],
            ),
          ),
        ];
      },
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight + kTextTabBarHeight),
          child: Container(
            child: new TabBarView(
              controller: _tabController,
              children: [
                MethodePresentationScreen(methode: widget.methode,),
                MethodeAvantageScreen(methode: widget.methode,),
                MethodeInconvenientScreen(methode: widget.methode,),
                MethodeCentresScreen(methode: widget.methode,),
              ],
            ),
          )
        )
      )
    ); 
  }
}





class MethodePresentationScreen extends StatefulWidget {
  MethodePresentationScreen({Key key, this.methode}) : super(key: key);
  Methode methode;
  @override
  State createState() => new MethodePresentationScreenState();
}

class MethodePresentationScreenState extends State<MethodePresentationScreen> {
  MethodePresentationScreenState();
  bool isLoading = false;
  
  bool _isPlaying = false;
  bool _onPause = false;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;
  FlutterSound flutterSound;
  double slider_current_position = 0.0;
  double max_duration = 1.0;

  String _playerTxt = '00:00';
  double _dbLevel;
  String mp3Uri;

  @override
  void initState() { 
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
    initializeDateFormatting();
  }


  @override
  void dispose() {
    // TODO: implement dispose
    if(_isPlaying) {
      stopPlayer();
      _playerSubscription.cancel();
      _dbPeakSubscription.cancel();
    }
    super.dispose();
  }

  void startPlayer(path) async{
    // Directory appDocDirectory = await DefaultAssetBundle();
    
    final ByteData data = await rootBundle.load('assets/audios/spot_haoussa_implant.mp3');
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/demo.mp3');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    mp3Uri = tempFile.uri.toString();

    String pathh = await flutterSound.startPlayer(mp3Uri);
    await flutterSound.setVolume(1.0);
    print('startPlayer: $pathh');
    try {
      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          slider_current_position = e.currentPosition;
          max_duration = e.duration;

          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt(),
              isUtc: true);
          String txt = DateFormat('mm:ss', 'en_GB').format(date);
          this.setState(() {
            this._isPlaying = true;
            this._playerTxt = txt.substring(0, 5);
          });
        }
      });
      _playerSubscription.onDone((){
        print('player done =========');
        setState(() {
          _isPlaying = false;
        });
      });
    } catch (err) {
      print('error: $err');
    }
  }

  void stopPlayer() async{
    try {
      String result = await flutterSound.stopPlayer();
      print('stopPlayer: $result');
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }

      this.setState(() {
        slider_current_position = 0.0;
        this._isPlaying = false;
        this._playerTxt = "00:00";
      });
    } catch (err) {
      print('error: $err');
    }
  }

  void pausePlayer() async{
    
    String result = await flutterSound.pausePlayer();
    
    setState(() {
      this._isPlaying = false;
      this._onPause = true;
    });
    print('pausePlayer: $result');
  }

  void resumePlayer() async{
    String result = await flutterSound.resumePlayer();
    setState(() {
      this._onPause = false;
    });
    print('resumePlayer: $result');
  }

  void seekToPlayer(int milliSecs) async{
    int secs = Platform.isIOS ? milliSecs / 1000 : milliSecs;

    String result = await flutterSound.seekToPlayer(secs);
    print('seekToPlayer: $result');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          startPlayer(widget.methode.audio_ha);
        },
        tooltip: 'Ecouter un audio',
        child: const Icon(MdiIcons.headphones),
      ),
      body: 
      Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton.icon(
                  color: Colors.green,
                  icon: Icon(Icons.headset, color: Colors.white,), //`Icon` to display
                  label: Text('Ecouter en Haoussa',  style: TextStyle(color: Colors.white),), //`Text` to display
                  onPressed: () {
                    //Code to execute when Floating Action Button is clicked
                    //...
                  },
                ),
                FlatButton.icon(
                  color: Colors.green,
                  icon: Icon(Icons.headset, color: Colors.white,), //`Icon` to display
                  label: Text('Ecouter en Zarma', style: TextStyle(color: Colors.white),), //`Text` to display
                  onPressed: () {
                    //Code to execute when Floating Action Button is clicked
                    //...
                  },
                ),
              ],
            )),
          Html(
            data: """
      ${widget.methode.subtitle}
      """,
            //Optional parameters:
            padding: EdgeInsets.all(8.0),
            defaultTextStyle: TextStyle(fontSize: 20),
            onLinkTap: (url) {
              print("Opening $url...");
            },
            customRender: (node, children) {
              if (node is dom.Element) {
                switch (node.localName) {
                  case "custom_tag":
                    return Column(children: children);
                }
              }
            },
          ),
        ],
      )
      
    );
  }
}

class MethodeInconvenientScreen extends StatefulWidget {
  MethodeInconvenientScreen({Key key, this.methode}) : super(key: key);
  Methode methode;

  @override
  State createState() => new MethodeInconvenientScreenState();
}

class MethodeInconvenientScreenState extends State<MethodeInconvenientScreen> {
  MethodeInconvenientScreenState();
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
        tooltip: 'Ecouter un audio',
        child: const Icon(MdiIcons.headphones),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Text("${widget.methode.inconvenient}" , style: TextStyle(fontSize: 20)),
      ),
    );
  }
}



class MethodeCentresScreen extends StatefulWidget {
  MethodeCentresScreen({Key key, this.methode}) : super(key: key);
  Methode methode;
  @override
  State createState() => new MethodeCentresScreenState();
}

class MethodeCentresScreenState extends State<MethodeCentresScreen> {
  MethodeCentresScreenState();
  bool isLoading = false;
  List centres = [];

  @override
  void initState() { 
    super.initState();
    centres = [
      {
        'id': 1,
        'nom': "Centre 1",
        'image': 'images/cart1.png',
        'dispo': true
      },
      {
        'id': 1,
        'nom': "Centre 1",
        'image': 'images/cart2.png',
        'dispo': false
      },
      {
        'id': 1,
        'nom': "Centre 1",
        'image': 'images/cart1.png',
        'dispo': true
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Ecouter un audio',
        child: const Icon(MdiIcons.headphones),
      ),
      body: ListView.builder(
        itemCount: centres.length,
        itemBuilder: (context, index){
          return ExpansionTile(
            leading: null,
            title: ListTile(
              contentPadding: EdgeInsets.only(left: 0),
              title: new Text(centres[index]['nom']),
              leading: CircleAvatar(
                backgroundColor: centres[index]['dispo'] ? Colors.green : Colors.red,
              ),
              subtitle: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                new Text("Disponible: ", maxLines: 1, overflow: TextOverflow.ellipsis),
                new Container(
                  padding: EdgeInsets.all(2),
                  decoration: new BoxDecoration(
                    color: centres[index]['dispo'] ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              ],)
            ),
            children: [
              Container(
                color: Colors.black12,
                child: Image.asset(
                  centres[index]['image'],
                  fit: BoxFit.fill,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}






class MethodeAvantageScreen extends StatefulWidget {
  MethodeAvantageScreen({Key key, this.methode}) : super(key: key);
  Methode methode;

  @override
  State createState() => new MethodeAvantageScreenState();
}

class MethodeAvantageScreenState extends State<MethodeAvantageScreen> {
  MethodeAvantageScreenState();
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
        tooltip: 'Ecouter un audio',
        child: const Icon(MdiIcons.headphones),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Text("${widget.methode.avantage}", style: TextStyle(fontSize: 20),),
      ),
    );
  }
}