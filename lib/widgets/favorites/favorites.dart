import 'dart:convert';
import 'dart:io';

import 'package:audiotales/widgets/filmstrips/filmsrtripArchive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:audiotales/modelJSON/taleInf.dart';
import 'package:audiotales/main.dart';
import 'package:audiotales/widgets/texts/textPage.dart';
import 'package:audiotales/widgets/music/player/musicPlayer.dart';
import 'package:audiotales/widgets/audioTales/player/audioTalesPlayer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audiotales/modelJSON/globalData.dart';

class Favorites extends StatefulWidget{

  Favorites({Key key,}) : super(key: key);

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  int _selectedIndex = 0;
  File jsonFile;
  Directory dir;
  String favoriteAudioTale = "favoriteAudioTale.json";
  String favoriteText = "favoriteText.json";
  String favoriteMusic = "favoriteMusic.json";
  String favoriteFilmstrip = "favoriteFilmstrip.json";

  bool fileExists = false;
  String pathToLocal;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if(index == 0){
      getApplicationDocumentsDirectory().then((Directory directory) {
        dir = directory;
        jsonFile = new File(dir.path + "/" + favoriteAudioTale);
        fileExists = jsonFile.existsSync();
        if (fileExists)
        {
          favoriteDataAudioTale = json.decode(jsonFile.readAsStringSync());
          favoriteDataAudioTale = favoriteDataAudioTale.map((fav) => new AudioTaleDetailsJSON.fromJson(fav)).toList();
        }
      });
    }
    if (index == 1) {
      getApplicationDocumentsDirectory().then((Directory directory) {
        dir = directory;
        jsonFile = new File(dir.path + "/" + favoriteText);
        fileExists = jsonFile.existsSync();
        if (fileExists) {
          favoriteDataText = json.decode(jsonFile.readAsStringSync());
          favoriteDataText =
              favoriteDataText.map((fav) => new TextDetailsJSON.fromJson(fav))
                  .toList();
              }
         });
      }
      if (index == 2) {
          getApplicationDocumentsDirectory().then((Directory directory) {
            dir = directory;
            jsonFile = new File(dir.path + "/" + favoriteMusic);
            fileExists = jsonFile.existsSync();
            if (fileExists)
            {
              favoriteDataMusic = json.decode(jsonFile.readAsStringSync());
              favoriteDataMusic = favoriteDataMusic.map((fav) => new MusicDetailsJSON.fromJson(fav)).toList();
            }
          });
       }
      if (index == 3) {
        getApplicationDocumentsDirectory().then((Directory directory) {
          dir = directory;
          jsonFile = new File(dir.path + "/" + favoriteFilmstrip);
          fileExists = jsonFile.existsSync();
          if (fileExists)
          {
            favoriteDataFilmstrip = json.decode(jsonFile.readAsStringSync());
            favoriteDataFilmstrip = favoriteDataFilmstrip.map((fav) => new FilmstripDetailsJSON.fromJson(fav)).toList();
          }
        });
      }
    }



  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + favoriteAudioTale);
      fileExists = jsonFile.existsSync();
      if (fileExists)
      {
        favoriteDataAudioTale = json.decode(jsonFile.readAsStringSync());
        favoriteDataAudioTale = favoriteDataAudioTale.map((fav) => new AudioTaleDetailsJSON.fromJson(fav)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: new NavDrawer(),
      appBar: AppBar(
        title: Text('Любимое'),
      ),
      body: _selectedIndex == 0
          ? Container(child: _pushFavoritesAudioTale(context),)
          : (_selectedIndex == 1
          ? Container(child: _pushFavoritesText(context))
          : _selectedIndex == 2
          ? Container(child:  _pushFavoritesMusic(context))
          : Container(child: _pushFavoritesFilmstrip(context))),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.headset, color: Colors.black,),
              title: Text('Аудиосказки')),
          BottomNavigationBarItem(
              icon: Icon(Icons.book, color: Colors.black),
              title: Text('Тексты')),
          BottomNavigationBarItem(
              icon: Icon(Icons.music_note, color: Colors.black),
              title: Text('Музыка')),
          BottomNavigationBarItem(
              icon: Icon(Icons.picture_in_picture, color: Colors.black),
              title: Text('Диафильмы')),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _pushFavoritesText(BuildContext context) {
    return ListView.builder(
        itemCount: favoriteDataText.length,
        // ignore: missing_return
        itemBuilder: (BuildContext context, int index) {
          var id = favoriteDataText[index].id;
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
                                          favoriteDataText[index]
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
                                            1.0)
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: Padding(
                                          child: Text(
                                            favoriteDataText[index]
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
                                              .only(top: 5.0)
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Padding(
                                        child: Text(
                                          favoriteDataText[index]
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
                                    Row(
                                      children: <Widget>[
                                        Container(
                                            margin: EdgeInsets
                                                .only(
                                                left: 100.0)),
                                      ],
                                    )
                                  ],
                                ),
                              ]
                          )
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            onTap: () {
              var route = new MaterialPageRoute(
                builder: (BuildContext context) =>
                new TextPage(textDetailsJSON: favoriteDataText[index]),
              );
              Navigator.of(context).push(route);
            },
          );
        }
    );
  }

  Widget _pushFavoritesAudioTale(BuildContext context) {
     return ListView.builder(
         itemCount: favoriteDataAudioTale.length,
         // ignore: missing_return
         itemBuilder: (BuildContext context, int index) {
           var id = favoriteDataAudioTale[index].id;
           String imageURL = 'URL';
           bool checkSave = false;
           var sizeConvert = filesize(int.parse(favoriteDataAudioTale[index].size));

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
                       imageUrl: (Platform.isIOS && favoriteDataAudioTale[index].iosImage == '1')
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
                                           favoriteDataAudioTale[index]
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
                                             favoriteDataAudioTale[index]
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
                                               .only(top: 5.0)
                                       ),
                                     )
                                   ],
                                 ),
                                 Row(
                                   children: <Widget>[
                                     Padding(
                                         child: Text(
                                           favoriteDataAudioTale[index]
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
                               ]
                           )
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
                     audioTaleDetailsJSON: favoriteDataAudioTale[index]),
               );
               Navigator.of(context).push(route);
               },
           );
         }
     );
  }

  Widget _pushFavoritesMusic(BuildContext context) {
    return ListView.builder(
        itemCount: favoriteDataMusic.length,
        // ignore: missing_return
        itemBuilder: (BuildContext context, int index) {
          bool checkSave = false;
          var id = favoriteDataMusic[index].id;
          var sizeConvert = filesize(int.parse(favoriteDataMusic[index].size));
          String imageURL = 'URL';

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
                                          favoriteDataMusic[index]
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
                                            1.0)
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Padding(
                                        child: Text(
                                          favoriteDataMusic[index]
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
                                            top: 5.0)),
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
                new MusicPlayer(
                    musicDetailsJSON: favoriteDataMusic[index]),
              );
              Navigator.of(context).push(route);
            },
          );
        }
    );
  }

  Widget _pushFavoritesFilmstrip(BuildContext context) {
    return ListView.builder(
        itemCount: favoriteDataFilmstrip.length,
        // ignore: missing_return
        itemBuilder: (BuildContext context, int index) {
          bool checkSave = false;
          var id = favoriteDataFilmstrip[index].id;
          var sizeConvert = filesize(int.parse(favoriteDataFilmstrip[index].size));
          String imageURL = 'URL';

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
                                          favoriteDataFilmstrip[index]
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
                                            1.0)
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Padding(
                                        child: Text(
                                          favoriteDataFilmstrip[index].author,
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
                                          favoriteDataFilmstrip[index]
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
                                            top: 5.0)),
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
                new FilmstripArchive(
                    filmstripDetailsJSON: favoriteDataFilmstrip[index]),
              );
              Navigator.of(context).push(route);
            },
          );
        }
    );
  }
}