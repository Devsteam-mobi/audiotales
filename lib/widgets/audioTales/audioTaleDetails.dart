import 'dart:convert';
import 'dart:io';

import 'package:audiotales/modelJSON/globalData.dart';
import 'package:audiotales/modelJSON/taleInf.dart';
import 'package:audiotales/widgets/audioTales/player/audioTalesPlayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audiotales/modelJSON/admob.dart';

const String testDevice = 'F9DFBA416DCF6AA55E05AC814CBB527C';

class AudioTaleDetails extends StatefulWidget{
  final TaleInf taleInf;
  final AudioTaleDetailsJSON audioTaleDetailsJSON;
  String checkId;

  AudioTaleDetails({Key key, this.taleInf, this.audioTaleDetailsJSON}) : super(key: key);

  @override
  _AudioTaleDetailsState createState() => _AudioTaleDetailsState();
}

class _AudioTaleDetailsState extends State<AudioTaleDetails> {

  @override
  void initState() {
    FirebaseAdMob.instance.initialize(
        appId: getAppId());
    super.initState();
      _loadData();
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    audioTaleList = prefs.getStringList('audioTaleList');
    if(audioTaleList == null){
      audioTaleList = [];
    }
  }

  Future<List<AudioTaleDetailsJSON>> audioTaleDetailsAPI() async{
    var id = widget.taleInf.id;
    var response = await http.get('URL');

    if(response.statusCode == 200){
      List audioTaleDetailsURL = json.decode(utf8.decode(response.bodyBytes));
      return audioTaleDetailsURL
          .map((audioTaleDetailsURL) => new AudioTaleDetailsJSON.fromJson(audioTaleDetailsURL))
          .toList();
    } else
      throw Exception('fail in load data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text(widget.taleInf.name),
        ),
        body: Container(
          child: new FutureBuilder<List<AudioTaleDetailsJSON>>(
              future: audioTaleDetailsAPI(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                        if (widget.taleInf.id == snapshot.data[index].stId) {
                          bool checkSave = false;
                          var id = snapshot.data[index].id;
                          String imageURL = 'URL';
                          var sizeConvert = filesize(int.parse(snapshot.data[index].size));

                          void save() {
                            if ( audioTaleList != null && audioTaleList.length > 0) {
                              for (int i = 0; i < audioTaleList.length; i++) {
                                var count = File(audioTaleList[i]).path
                                    .split('/')
                                    .last;
                                if (count == '$id.mp3') {
                                  checkSave = true;
                                } else if (audioTaleList.length == i) {
                                  break;
                                } else
                                  continue;
                              }
                            }
                          }
                          save();
                          return ListTile(
                            title: new Card (
                              elevation: 1.0,
                              child: new Container(
                                padding: EdgeInsets.all(5.0),
                                margin: EdgeInsets.all(5.0),
                                child: Column(
                                  children: <Widget>[
                                    CachedNetworkImage(
                                      imageUrl: (Platform.isIOS && snapshot.data[index].iosImage == '1')
                                          ? imageUrlDefAudio
                                          :imageURL,
                                      height: imageItems,
                                      width: imageItems,
                                      placeholder: (context, url) => new CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => new Image.asset(
                                        imageUrlDefAudio,
                                        width: imageItems,
                                        height: imageItems,
                                      ),
                                    ),
                                    Row(children: <Widget>[
                                      Flexible(
                                          child: Wrap(
                                              direction: Axis.horizontal,
                                              children: <Widget>[
                                                Wrap(
                                                  children: <Widget>[
                                                    Padding(
                                                        child: Text(
                                                          snapshot.data[index]
                                                              .name,
                                                          textAlign: TextAlign
                                                              .right,
                                                          style: (TextStyle(
                                                            fontSize: fontSize,
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          )),
                                                        ),
                                                        padding: EdgeInsets.all(
                                                            1.0)),
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Flexible(
                                                      child: Padding(
                                                          child: Text(
                                                            snapshot.data[index]
                                                                .author,
                                                            style: (TextStyle(
                                                              fontSize: fontSize,
                                                              color: Colors
                                                                  .lightBlueAccent,
                                                              fontStyle: FontStyle
                                                                  .italic,
                                                            )),
                                                          ),
                                                          padding: EdgeInsets
                                                              .only(top: 5.0)),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                        child: Text(
                                                          snapshot.data[index]
                                                              .duration,
                                                          textAlign: TextAlign
                                                              .right,
                                                          style: (TextStyle(
                                                            fontSize: fontSize,
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          )),
                                                        ),
                                                        padding: EdgeInsets.only(
                                                            top: 5.0)
                                                    ),
                                                  ],
                                                ),
                                              ])
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Padding(
                                              child:Text( checkSave
                                                  ? 'Сохранено'
                                                  : sizeConvert,
                                                textAlign: TextAlign
                                                    .right,
                                                style: (TextStyle(
                                                  fontSize: fontSize,
                                                  fontWeight: FontWeight
                                                      .bold,
                                                  fontStyle: FontStyle
                                                      .italic,
                                                )),
                                              ),
                                              padding: EdgeInsets
                                                  .all(1.0),
                                            ),
                                          )],
                                      )
                                    ]),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              var route = new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                new AudioTalePlayer(
                                    audioTaleDetailsJSON: snapshot.data[index]),
                              );
                              Navigator.of(context).push(route);
                            },
                          );
                        }
                      }
                  );
                }
              }
          ),
        ),
      floatingActionButton: isPlaying ? FloatingActionButton(
        onPressed: stop,
        child: Icon(Icons.pause),
      ) : Center(),
      );
  }
}