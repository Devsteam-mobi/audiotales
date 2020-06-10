import 'dart:io';

import 'package:audiotales/modelJSON/taleInf.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audiotales/widgets/music/player/musicPlayer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audiotales/modelJSON/globalData.dart';

class MusicDetails extends StatefulWidget{
  final TaleInf taleInf;
  final MusicDetailsJSON musicDetailsJSON;

  MusicDetails({Key key, this.taleInf, this.musicDetailsJSON}) : super(key: key);

  @override
  _MusicDetailsState createState() => _MusicDetailsState();
}

class _MusicDetailsState extends State<MusicDetails>{

  @override
  void initState(){
    _loadData();
  super.initState();
  }

void _loadData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  audioTaleList = prefs.getStringList('audioTaleList');
  if(audioTaleList == null){
    audioTaleList = [];
  }
}

  Future<List<MusicDetailsJSON>> musicDetailsAPI() async {
    var id = widget.taleInf.id;
    var response = await http.get('URL');


    if (response.statusCode == 200) {
      List musicDetailsURL = json.decode(utf8.decode(response.bodyBytes));
      return musicDetailsURL
          .map((musicDetailsJSON) => new MusicDetailsJSON.fromJson(musicDetailsJSON))
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
            child: new FutureBuilder<List<MusicDetailsJSON>>(
              future: musicDetailsAPI(),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.data == null){
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
                          var id = snapshot.data[index].id;
                          String imageURL = 'URL';
                          bool checkSave = false;
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
                              title: new Card(
                                elevation: 1.0,
                                child: new Container(
                                  padding: EdgeInsets.all(5.0),
                                  margin: EdgeInsets.all(5.0),
                                  child: Column(
                                    children: <Widget>[
                                      CachedNetworkImage(
                                        imageUrl: imageURL,
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
                                                            snapshot.data[index].name,
                                                            textAlign: TextAlign.right,
                                                            style: (TextStyle(
                                                              fontSize: fontSize,
                                                              fontWeight: FontWeight.bold,
                                                              fontStyle: FontStyle.italic,
                                                            )),
                                                          ),
                                                          padding: EdgeInsets.all(1.0)
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Padding(
                                                          child: Text(
                                                            snapshot.data[index].duration,
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
                                                ]
                                            ),
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
                            onTap: (){
                                var route = new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                new MusicPlayer(musicDetailsJSON: snapshot.data[index]),
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
        );
  }
}