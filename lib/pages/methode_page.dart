import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gagasiney/models/models.dart';
import 'package:gagasiney/pages/methode_detail_page.dart';
import 'package:gagasiney/utils/utils.dart';

class MethodeScreen extends StatefulWidget {
  MethodeScreen({Key key, this.data}) : super(key: key);
  PF data;
  @override
  State createState() => new MethodeScreenState();
}

class MethodeScreenState extends State<MethodeScreen> {
  MethodeScreenState();
  bool isLoading = false;
  List methodes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.data.title}'),
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
                StreamBuilder(
                  stream: Firestore.instance.collection('gagasiney/app/methodes').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
                      );
                    } else {
                      if(snapshot.data.documents.length == 0){
                        return new Center(
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Icon(
                                Icons.info_outline,
                                size: 150.0,
                                color: Colors.black12
                              ),
                              Text('no data found',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.black38
                                )
                              )
                            ],
                          ),
                        );
                      }else{
                        return ListView.builder(
                          padding: EdgeInsets.only(top: 10),
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, int index){
                              Methode methode = Methode.fromJson(snapshot.data.documents[index].data);
                              print(methodes);
                              return Container(
                                height: 80,
                                child: InkWell(
                                  onTap: (){
                                    Navigator.push(context, new MaterialPageRoute(
                                      builder: (context) => new MethodeDetailScreen(
                                        methode: methode,
                                      )
                                    ));
                                  },
                                  child: Card(
                                  elevation: 2,
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        // color: Colors.green,
                                        height: 80,
                                        width: 80 * 1.6,
                                        padding: EdgeInsets.all(4),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(3),
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
                                            imageUrl: methode.image,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Padding(padding: EdgeInsets.only(left: 8)),
                                      Expanded(
                                        child: ListTile(
                                          contentPadding: EdgeInsets.all(0),
                                          title: Text(methode.title),
                                          subtitle: Text(methode.subtitle,
                                          overflow: TextOverflow.ellipsis, maxLines: 2,),
                                        ),
                                      )
                                    ],
                                  )
                              ),
                                ),
                            );
                          },
                        );
                      }
                    }
                  },
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
      ),
    );
  }
}