import 'package:audiotales/modelJSON/admob.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audiotales/modelJSON/taleInf.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:audiotales/modelJSON/globalData.dart';


class FilmDetails extends StatefulWidget{
  final TaleInf taleInf;
  final FilmDetailsJSON filmDetailsJSON;

  FilmDetails({Key key, this.taleInf, this.filmDetailsJSON}) : super(key: key);

  @override
  _FilmDetailsState createState() => _FilmDetailsState();
}

class _FilmDetailsState extends State<FilmDetails>{

  Future<List<FilmDetailsJSON>> filmDetailsAPI() async{
    var id = widget.taleInf.id;
    var response = await http.get('URL');


    if(response.statusCode == 200){
      List filmDetailsURL = json.decode(utf8.decode(response.bodyBytes));
      return filmDetailsURL
          .map((filmDetailsURL) => new FilmDetailsJSON.fromJson(filmDetailsURL))
          .toList();
    } else
      throw Exception('fail in load data');
  }

  InterstitialAd _interstitialAd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: new AppBar(
            title: new Text(widget.taleInf.name),
          ),
          body: Container(
            child: new FutureBuilder<List<FilmDetailsJSON>>(
                future: filmDetailsAPI(),
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
                            InterstitialAd myInterstitial() {
                              _interstitialAd = InterstitialAd(
                                  adUnitId: getInterstitialAdUnitId(),
                                  targetingInfo: targetingInfo,
                                  listener: (MobileAdEvent event) {
                                    if (event == MobileAdEvent.loaded) {
                                      _interstitialAd.show(anchorType: AnchorType.bottom);
                                    }
                                    if (event == MobileAdEvent.opened || event == MobileAdEvent.failedToLoad) {
                                      //load youtubePlayer
                                      void playYoutubeVideoIdEditAuto() {
                                        FlutterYoutube.onVideoEnded.listen((onData) {
                                        });
                                        FlutterYoutube.playYoutubeVideoById(
                                            apiKey: "<API_KEY>",
                                            videoId: snapshot.data[index].url,
                                            autoPlay: true);
                                      }
                                      return playYoutubeVideoIdEditAuto();
                                    }
                                  })
                                ..load();
                            }

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
                                          imageUrlDefVideo,
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
                                                            snapshot.data[index].author,
                                                            textAlign: TextAlign.right,
                                                            style: (TextStyle(
                                                              fontSize: fontSize,
                                                              color: Colors.lightBlueAccent,
                                                              fontStyle: FontStyle.italic,
                                                            )),
                                                          ),
                                                          padding: EdgeInsets.only(top: 5.0)
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
                                                          padding: EdgeInsets.only(top: 5.0)),
                                                      Row(
                                                        children: <Widget>[
                                                          Container(margin: EdgeInsets.only( left: 90.0)),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ]
                                            ),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: (){
                                myInterstitial();
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