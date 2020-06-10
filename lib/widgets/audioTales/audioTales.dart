import 'dart:async';

import 'package:audiotales/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audiotales/modelJSON/taleInf.dart';
import 'package:audiotales/resource/api/api.dart';
import 'package:audiotales/widgets/audioTales/audioTaleDetails.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:audiotales/modelJSON/globalData.dart';

class AudioTalePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  void show(){
    Timer.run(() => _key.currentState.openDrawer());
    isOpenDrawerOnStart = true;
  }

  @override
  Widget build(BuildContext context) {
    if(isOpenDrawerOnStart == false) {
      show();
    }
    return new Scaffold(
      key: _key,
      drawer: new NavDrawer(),
      appBar: new AppBar(
        title: new Text('Аудиосказки'),
      ),
      body: Container(
        child: new FutureBuilder<List<TaleInf>>(
          future: audioTaleAPI(),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container(
                child: Center(
                  child: SpinKitFadingCircle(
                    color: Colors.black45,
                    size: 70.0,
                  ),
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  // ignore: missing_return
                  itemBuilder: (BuildContext context, int index) {
                    var id = snapshot.data[index].id;
                    String imageURL = 'URL';

                    return new ListTile(
                        title: new Card(
                          elevation: 20.0,
                          child: new Container(
                            padding: EdgeInsets.all(5.0),
                            margin: EdgeInsets.all(5.0),
                            child: Column(
                              children: <Widget>[
                                Row(children: <Widget>[
                                  CachedNetworkImage(
                                    imageUrl: imageURL,
                                    height: imageSets,
                                    width: imageSets,
                                    placeholder: (context, url) => new CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => new Image.asset(
                                      imageUrlDefAudio,
                                      width: imageSets,
                                      height: imageSets,
                                    ),
                                  ),
                                  SizedBox(width: 10.0,),
                                  Container(
                                   child: Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: <Widget>[
                                        Padding(
                                            child: Text(
                                              snapshot.data[index].name,
                                              style: (TextStyle(
                                                fontSize: fontSize,
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FontStyle.italic,
                                              )),
                                            ),
                                            padding: EdgeInsets.all(1.0)),
                                        Padding(
                                            child: Text(
                                              snapshot.data[index].desc,
                                              style: (TextStyle(
                                                fontSize: fontSize,
                                                color: Colors.lightBlueAccent,
                                                fontStyle: FontStyle.italic,
                                              )),
                                            ),
                                            padding: EdgeInsets.only(top: 5.0)),
                                        Padding(
                                            child: Text(
                                              snapshot.data[index].count,
                                              textAlign: TextAlign.right,
                                              style: (TextStyle(
                                                fontSize: fontSize,
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FontStyle.italic,
                                              )),
                                            ),
                                            padding: EdgeInsets.only(top: 5.0)
                                        ),
                                      ],
                                    ),
                                   ),
                                  )
                                ]),
                              ],
                            ),
                          ),
                        ),
                        onTap: (){
                          var route = new MaterialPageRoute(
                            builder: (BuildContext context) =>
                            new AudioTaleDetails(taleInf: snapshot.data[index]),
                          );
                          Navigator.of(context).push(route);
                        }
                    );
                  }
                  );
            }
          },
        )
      ),
      floatingActionButton: isPlaying ? FloatingActionButton(
        onPressed: stop,
        child: Icon(Icons.pause),
      ) : Center(),
    );
  }
}