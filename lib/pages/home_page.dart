
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:gagasiney/pages/methode_page.dart';
import 'package:gagasiney/models/models.dart';
import 'package:gagasiney/pages/pf_page.dart';
import 'package:gagasiney/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  State createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenState();
  bool isLoading = false;
  List<Menu> datas = <Menu>[
    Menu.fromJson({
      'id': 1,
      'title': "Planing Familiale",
      'image': "http://www.cridecigogne.org/sites/default/files/images_publications/planification-familiale.jpg",
      'statut': true
    }),
    Menu.fromJson({
      'id': 2,
      'title': "Violences",
      'image': "https://monusco.unmissions.org/sites/default/files/styles/full_width_image/public/field/image/violences-sexuelles-logo-3.jpeg?itok=UrZby6G_",
      'statut': false
    }),
  ];

   Future<bool> onBackPress() {
    openDialog(context);
    return Future.value(false);
  }

  Widget sliders(){
    return Container(
    child: new SizedBox(
      height: 200.0,
      child: 
      new StreamBuilder(
        stream: Firestore.instance.collection('gagasiney/app/sliders').snapshots(),
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GAGASSINEY'),
      ),
      body: WillPopScope(
        child: 
         NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                
              ];
            },
            body:  new Container(
            child: Stack(
              children: <Widget>[
                sliders(),
                GridView.builder(
                  padding: EdgeInsets.only(top: 220),
                  itemCount: datas.length,
                  itemBuilder: (context, int index){
                    Menu pf = datas[index];
                    return InkWell(
                      onTap: (){
                        if(pf.statut){
                          Navigator.push(context, new MaterialPageRoute(
                            builder: (context) => new PFScreen()
                          ));
                        }
                      },
                      child: Card(
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 150,
                              width: 200,
                              child: CachedNetworkImage(
                                placeholder: Container(
                                  child: Center(
                                    child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                                  ),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                                errorWidget: Material(
                                  child: Image.asset(
                                    'assets/images/img_not_available.jpeg',
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                                imageUrl: pf.image ?? '',
                                fit: BoxFit.cover,
                                // height: 100,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(pf.title, style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),),
                            )
                          ],
                        )
                      ),
                    );
                  }, gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                                   crossAxisCount: 2),
                ),
                Positioned(
                  child: isLoading
                      ? Container(
                          child: Center(
                            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
                          ),
                          color: Colors.white.withOpacity(0.8),
                        )
                      : Container(),
                )
              ],
            ),
          ),
        ),
        onWillPop: onBackPress,
      ),
    );
  }
}