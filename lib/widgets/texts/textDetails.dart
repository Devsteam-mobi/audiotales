import 'package:audiotales/widgets/texts/textPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audiotales/modelJSON/taleInf.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audiotales/modelJSON/globalData.dart';

class TextDetails extends StatefulWidget{
  final TaleInf taleInf;
  final TextDetailsJSON textDetailsJSON;

  TextDetails({Key key, this.taleInf, this.textDetailsJSON}) : super(key: key);

  @override
  _TextDetailsState createState() => _TextDetailsState();
}

class _TextDetailsState extends State<TextDetails>{

  Future<List<TextDetailsJSON>> textDetailsAPI() async{
    var id = widget.taleInf.id;
    var response = await http.get('URL');

    if(response.statusCode == 200){
      List textDetailsURL = json.decode(utf8.decode(response.bodyBytes));
      return textDetailsURL
          .map((textDetailsURL) => new TextDetailsJSON.fromJson(textDetailsURL))
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
            child: new FutureBuilder<List<TextDetailsJSON>>(
                future: textDetailsAPI(),
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
                            String imageURL = 'URL';

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
                                            imageUrlDefText,
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
                                                            padding: EdgeInsets.only(top: 5.0)
                                                        ),
                                                        Row(
                                                          children: <Widget>[
                                                            Container(margin: EdgeInsets.only( left: 90.0)),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                              ),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ),
                                ),
                              onTap: (){
                              var route = new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                new TextPage(textDetailsJSON: snapshot.data[index]),
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