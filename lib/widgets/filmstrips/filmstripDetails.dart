import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audiotales/modelJSON/taleInf.dart';
import 'package:audiotales/widgets/filmstrips/filmsrtripArchive.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audiotales/modelJSON/globalData.dart';

class FilmstripDetails extends StatefulWidget{
  final TaleInf taleInf;
  final FilmstripDetailsJSON filmstripDetailsJSON;

  FilmstripDetails({Key key, this.taleInf, this.filmstripDetailsJSON}) : super(key: key);

  @override
  _FilmstripDetailsState createState() => _FilmstripDetailsState();
}

class _FilmstripDetailsState extends State<FilmstripDetails>{

  Future<List<FilmstripDetailsJSON>> filmstripDetailsAPI() async{
    var id = widget.taleInf.id;
    var response = await http.get('URL');


    if(response.statusCode == 200){
      List filmstripDetailsURL = json.decode(utf8.decode(response.bodyBytes));
      return filmstripDetailsURL
          .map((textDetailsURL) => new FilmstripDetailsJSON.fromJson(textDetailsURL))
          .toList();
    } else
      throw Exception('fail in load data');
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: new AppBar(
            title: new Text(widget.taleInf.name),
          ),
          body: Container(
            child: new FutureBuilder<List<FilmstripDetailsJSON>>(
                future: filmstripDetailsAPI(),
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
                            var sizeConvert = filesize(int.parse(snapshot.data[index].size));
                            bool checkSave = false;

                            void save() {
                              if ( filmstripList != null && filmstripList.length > 0) {
                                for (int i = 0; i < filmstripList.length; i++) {
                                  var count = File(filmstripList[i]).path
                                      .split('/')
                                      .last;
                                  if (count == '$id'+ '_m.zip' || count == '$id.zip') {
                                    checkSave = true;
                                  } else if (filmstripList.length == i) {
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
                                                          padding: EdgeInsets.all(1.0)),
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
                                                          padding: EdgeInsets.only(top: 5.0)
                                                      ),
                                                    ],
                                                  ),
                                                ]
                                            )
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Padding(
                                                child:Text(checkSave
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
                                    new FilmstripArchive(filmstripDetailsJSON: snapshot.data[index]),
                                  );
                                  Navigator.of(context).push(route);
                                }
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