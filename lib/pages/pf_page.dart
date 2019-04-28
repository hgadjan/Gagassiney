
import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:gagasiney/pages/methode_page.dart';
import 'package:gagasiney/models/models.dart';
import 'package:gagasiney/utils/const.dart';
import 'package:gagasiney/utils/utils.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';

class PFScreen extends StatefulWidget {
  PFScreen({Key key}) : super(key: key);

  @override
  State createState() => new PFScreenState();
}

class PFScreenState extends State<PFScreen> {
  PFScreenState();


  bool _isPlaying = false;
  bool _onPause = false;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;
  FlutterSound _flutterSound;
  double slider_current_position = 0.0;
  double max_duration = 1.0;

  String _playerTxt = '00:00';
  double _dbLevel;
  String _mp3Uri;
  
  bool isLoading = false;
  List<PF> datas = <PF>[
    PF.fromJson({
      'id': 1,
      'title': "Methodes contraceptives",
      'subtitle': "Les differentes methodes contraceptives, leurs avantages et inconvenient",
      'statut': true
    }),
    PF.fromJson({
      'id': 2,
      'title': "Ou trouver ?",
      'subtitle': "Ou touver vos methodes contraceptives",
      'statut': false
    }),
    PF.fromJson({
      'id': 3,
      'title': "Comment faire son choix",
      'subtitle': "Conseils sur comment faire son choix et l'assistance",
      'statut': false
    })
  ];

  @override
  void initState() {
    super.initState();

    _flutterSound = new FlutterSound();
    _flutterSound.setSubscriptionDuration(0.01);
    _flutterSound.setDbPeakLevelUpdate(0.8);
    _flutterSound.setDbLevelEnabled(true);
    initializeDateFormatting();
  }

  void startPlayer(path) async{
    final ByteData data = await rootBundle.load(path);
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/demo.mp3');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    _mp3Uri = tempFile.uri.toString();

    String pathh = await _flutterSound.startPlayer(_mp3Uri);
    await _flutterSound.setVolume(1.0);
    print('startPlayer: $pathh');
    try {
      _playerSubscription = _flutterSound.onPlayerStateChanged.listen((e) {
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
      String result = await _flutterSound.stopPlayer();
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
    
    String result = await _flutterSound.pausePlayer();
    
    setState(() {
      this._isPlaying = false;
      this._onPause = true;
    });
    print('pausePlayer: $result');
  }

  void resumePlayer() async{
    String result = await _flutterSound.resumePlayer();
    setState(() {
      this._onPause = false;
    });
    print('resumePlayer: $result');
  }

  void seekToPlayer(int milliSecs) async{
    int secs = Platform.isIOS ? milliSecs / 1000 : milliSecs;

    String result = await _flutterSound.seekToPlayer(secs);
    print('seekToPlayer: $result');
  }



  Widget sliders(){
    return Container(
    child: new SizedBox(
      height: 200.0,
      child: 
      new StreamBuilder(
        stream: Firestore.instance.collection('gagasiney/app/sliders').where('acceuil', isEqualTo: true).snapshots(),
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
                        // valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                    ),
                    padding: EdgeInsets.all(70.0),
                    decoration: BoxDecoration(
                      color: Colors.grey,
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

  Widget buildBeforeSend(){
    return Container(
      child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    height: 20,
                    child: Slider(
                    value: slider_current_position,
                    min: 0,
                    max: max_duration,
                    onChanged: (double value) async{
                      seekToPlayer(value.toInt());
                    },
                    divisions: max_duration.toInt()
                  ),),
                  Container(
                    child: Text(_playerTxt ?? '00:00'),
                  ),
                    _isPlaying ? 
                  Row(
                    children: <Widget>[
                      
                      new Container(
                        margin: new EdgeInsets.symmetric(horizontal: 1.0),
                        child: new IconButton(
                          icon: _onPause ?  new Icon(Icons.play_arrow) : new Icon(Icons.pause),
                          onPressed: (){
                            if(this._onPause){
                              resumePlayer();
                            }else{
                              pausePlayer();
                            }
                          },
                          color: primaryColor,
                        ),
                      ),
                        new Container(
                        margin: new EdgeInsets.symmetric(horizontal: 1.0),
                        child: new IconButton(
                          icon: new Icon(Icons.stop),
                          onPressed: stopPlayer,
                          color: primaryColor,
                        ),
                      )
                    ],
                  ) :
                  new Container(
                    margin: new EdgeInsets.symmetric(horizontal: 1.0),
                    child: new IconButton(
                      icon: new Icon(Icons.play_arrow),
                      // onPressed: startPlayer,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ]
          )
      );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: <Widget>[
        SafeArea(
          child: _isPlaying ? buildBeforeSend() : Container(
            child: Text(''),
          )
        )
      ],
      appBar: AppBar(
        title: Text('Planification Familiale'),
      ),
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              
            ];
          },
          body:  new Container(
          child: Stack(
            children: <Widget>[
              sliders(),
              ListView.builder(
                padding: EdgeInsets.only(top: 200),
                itemCount: datas.length + 1,
                itemBuilder: (context, int index){
                  print(index);
                  if(index == 0){
                    return Container(
                      padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: 
                      Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              FlatButton.icon(
                                color: Colors.green,
                                icon: Icon(Icons.headset, color: Colors.white,), //`Icon` to display
                                label: Text('Spot en Haoussa',  style: TextStyle(color: Colors.white),), //`Text` to display
                                onPressed: () {
                                startPlayer('assets/audios/pf_haoussa.mp3');
                                },
                              ),
                              FlatButton.icon(
                                color: Colors.green,
                                icon: Icon(Icons.headset, color: Colors.white,), //`Icon` to display
                                label: Text('Spot en Zarma', style: TextStyle(color: Colors.white),), //`Text` to display
                                onPressed: () {
                                  startPlayer('assets/audios/pf_zarma.mp3');
                                },
                              ),
                            ],
                          )
                        ],
                      )
                    );
                  }else{
                    PF pf = datas[index - 1];
                    return InkWell(
                      onTap: (){
                        if(pf.statut){
                          Navigator.push(context, new MaterialPageRoute(
                            builder: (context) => new MethodeScreen(
                              data: datas[index - 1],
                            )
                          ));
                        }
                      },
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text("<=>"),
                          ),
                          title: Text(pf.title),
                          subtitle: Text(pf.subtitle,
                          overflow: TextOverflow.ellipsis, maxLines: 1,),
                        )
                      ),
                    );
                  }
                  
                },
              )
            ],
          ),
        ),
      )
    );
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
}