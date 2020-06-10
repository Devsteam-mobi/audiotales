import 'dart:io';

import 'package:audiotales/widgets/audioTales/player/audioTalesPlayer.dart';
import 'package:audiotales/widgets/music/player/musicPlayer.dart';
import 'package:audiotales/widgets/texts/textPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audiotales/modelJSON/taleInf.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:audiotales/modelJSON/globalData.dart';

import 'package:audiotales/resource/api/searchAPI.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../main.dart';


// type 7 - audiotales
// type 4 - music
// type 8 - filmstrip
// type 9 - texts
// type 2 - cartoons
// type 3 - films

class SearchPage extends StatefulWidget {
  final String url;

  SearchPage({this.url});

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState(url);
  }
}

class _SearchPageState extends State<SearchPage> {
  String url;
  _SearchPageState(this.url);
  List<SearchJSON> content = new List<SearchJSON>();
  //search audiotales
  List<AudioTaleDetailsJSON> audioTale = List();
  List<AudioTaleDetailsJSON> searchTale = List();
  //search music
  List<MusicDetailsJSON> musicTale = List();
  List<MusicDetailsJSON> searchMusicTale = List();
  //search film
  List<FilmDetailsJSON> filmTale = List();
  List<FilmDetailsJSON> searchFilmTale = List();
  //search filmstrip
  List<FilmstripDetailsJSON> filmstripTale = List();
  List<FilmstripDetailsJSON> searchFilmstripTale = List();
  //search cartoon
  List<CartoonDetailsJSON> cartoonTale = List();
  List<CartoonDetailsJSON> searchCartoonTale = List();
  //search text
  List<TextDetailsJSON> textTale = List();
  List<TextDetailsJSON> searchTextTale = List();

  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    SearchAPI.searchAudioTaleDetailsAPI().then((audioTaleFromServer) {
      setState(() {
        //search result AudioTales
        audioTale = audioTaleFromServer;
        searchTale = audioTale;
      });
    });
    SearchAPI.searchMusicDetailsAPI().then((musicsFromServer) {
      setState(() {
        //search result musics
        musicTale = musicsFromServer;
        searchMusicTale = musicTale;
      });
    });
    SearchAPI.searchFilmDetailsAPI().then((filmsFromServer) {
      setState(() {
        //search result films
        filmTale = filmsFromServer;
        searchFilmTale = filmTale;
      });
    });
    SearchAPI.searchFilmstripDetailsAPI().then((filmstripsFromServer) {
      setState(() {
        //search result Filmstrips
        filmstripTale = filmstripsFromServer;
        searchFilmstripTale = filmstripTale;
      });
    });
    SearchAPI.searchCartoonDetailsAPI().then((cartoonsFromServer) {
      setState(() {
        //search result Cartoons
        cartoonTale = cartoonsFromServer;
        searchCartoonTale = cartoonTale;
      });
    });
    SearchAPI.searchTextDetailsAPI().then((textsFromServer) {
      setState(() {
        //search result texts
        textTale = textsFromServer;
        searchTextTale = textTale;
      });
    });
  }
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool check = true;
    return Scaffold(
      drawer: new NavDrawer(),
      appBar: AppBar(
        title: TextFormField(
            onChanged: (String string) {
              setState(() {
                if (string.length >= 3 && check == true) {
                  if (_selectedIndex == 0) {
                    searchTale = audioTale.where((u) =>
                    (u.name.toLowerCase().contains(string.toLowerCase()) ||
                        u.author.toLowerCase().contains(string.toLowerCase())))
                        .toList();
                  } else if (_selectedIndex == 1) {
                    searchTextTale = textTale.where((u) =>
                    (u.name.toLowerCase().contains(string.toLowerCase()) ||
                        u.author.toLowerCase().contains(string.toLowerCase())))
                        .toList();
                  } else if (_selectedIndex == 2) {
                    searchMusicTale = musicTale.where((u) =>
                    (u.name.toLowerCase().contains(string.toLowerCase())))
                        .toList();
                  } else if (_selectedIndex == 3) {
                    searchFilmstripTale = filmstripTale.where((u) =>
                    (u.name.toLowerCase().contains(string.toLowerCase()) ||
                        u.author.toLowerCase().contains(string.toLowerCase())))
                        .toList();
                  }
                  else
                    if (_selectedIndex == 4) {
                    searchCartoonTale = cartoonTale.where((u) =>
                    (u.name.toLowerCase().contains(string.toLowerCase()) ||
                        u.author.toLowerCase().contains(string.toLowerCase())))
                        .toList();
                  } else {
                    searchFilmTale = filmTale.where((u) =>
                    (u.name.toLowerCase().contains(string.toLowerCase()) ||
                        u.author.toLowerCase().contains(string.toLowerCase())))
                        .toList();
                  }
                }
              });
            },
          style: Theme.of(context).textTheme.subtitle,
          controller: _controller,
          enableInteractiveSelection: false,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            fillColor: Colors.white,
            labelText: "Введите название или автора",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            contentPadding:
            EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.black,
              ),
              onPressed: () {
                _controller.clear();
                Fluttertoast.showToast(
                    msg: "Идет загрузка данных",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.lightBlueAccent,
                    textColor: Colors.white,
                    fontSize: 20.0);
                if (_selectedIndex == 0) {
                  SearchAPI.searchAudioTaleDetailsAPI().then((audioTaleFromServer) {
                    setState(() {
                      //search result AudioTales
                      audioTale = audioTaleFromServer;
                      searchTale = audioTale;
                    });
                  });
                } else if (_selectedIndex == 1) {
                  SearchAPI.searchTextDetailsAPI().then((textsFromServer) {
                    setState(() {
                      //search result texts
                      textTale = textsFromServer;
                      searchTextTale = textTale;
                    });
                  });
                } else if (_selectedIndex == 2) {
                  SearchAPI.searchMusicDetailsAPI().then((musicsFromServer) {
                    setState(() {
                      //search result musics
                      musicTale = musicsFromServer;
                      searchMusicTale = musicTale;
                    });
                  });
                } else if (_selectedIndex == 3) {
                  SearchAPI.searchFilmstripDetailsAPI().then((filmstripsFromServer) {
                    setState(() {
                      //search result Filmstrips
                      filmstripTale = filmstripsFromServer;
                      searchFilmstripTale = filmstripTale;
                    });
                  });
                }
                else if (_selectedIndex == 4) {
                  SearchAPI.searchCartoonDetailsAPI().then((cartoonsFromServer) {
                    setState(() {
                      //search result Cartoons
                      cartoonTale = cartoonsFromServer;
                      searchCartoonTale = cartoonTale;
                    });
                  });
                } else {
                  SearchAPI.searchFilmDetailsAPI().then((filmsFromServer) {
                    setState(() {
                      //search result films
                      filmTale = filmsFromServer;
                      searchFilmTale = filmTale;
                    });
                  });
                }
                },
        ),
        ),
        ),
      ),
      body: _selectedIndex == 0
          ? Container(
        child: Container(child: _pushSearchAudioTale()),)
          : (_selectedIndex == 1
          ? Container(child: Container(child: _pushSearchText()))
          : _selectedIndex == 2
          ? Container(child: Container(child: _pushSearchMusic()))
          : _selectedIndex == 3
          ? Container(child: Container(child: _pushSearchFilmstrip()))
          : _selectedIndex == 4
          ? Container(child: Container(child: _pushSearchCartoons()))
          : Container(child: Container(child: _pushSearchFilms()))
      ),

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
          BottomNavigationBarItem(
              icon: Icon(Icons.local_movies, color: Colors.black),
              title: Text('Мультфильмы')),
          BottomNavigationBarItem(
              icon: Icon(Icons.videocam, color: Colors.black),
              title: Text('Фильмы')),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _pushSearchText() {
    if(searchTextTale.length <= 0){
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
          itemCount: searchTextTale == null ? 0 : searchTextTale.length,
          // ignore: missing_return
          itemBuilder: (BuildContext context, int index) {
            var id = searchTextTale[index].id;
            String imageURL = 'URL';

            return Column(
              children: <Widget>[
                ListTile(
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
                                                  searchTextTale[index]
                                                      .name,
                                                  style: (TextStyle(
                                                    fontSize: fontSize,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    fontStyle: FontStyle
                                                        .italic,
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
                                                  searchTextTale[index]
                                                      .author,
                                                  textAlign: TextAlign
                                                      .right,
                                                  style: (TextStyle(
                                                    fontSize: fontSize,
                                                    color: Colors
                                                        .lightBlueAccent,
                                                    fontStyle: FontStyle
                                                        .italic,
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
                                                  searchTextTale[index]
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
                                                padding: EdgeInsets.only(top: 5.0)
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
                    onTap: () {
                      var route = new MaterialPageRoute(
                        builder: (BuildContext context) =>
                        new TextPage(textDetailsJSON: searchTextTale[index]),
                      );
                      Navigator.of(context).push(route);
                    }
                ),
              ],
            );
          }
      );
    }
  }

  Widget _pushSearchMusic() {
    if(searchMusicTale.length <= 0){
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
          itemCount: searchMusicTale == null ? 0 : searchMusicTale.length,
          // ignore: missing_return
          itemBuilder: (BuildContext context, int index) {
            var id = searchMusicTale[index].id;
            var sizeConvert = filesize(int.parse(searchMusicTale[index].size));
            bool checkSave = false;
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

            return Column(
              children: <Widget>[
                ListTile(
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
                                              searchMusicTale[index]
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
                                            padding: EdgeInsets.all(1.0)
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Padding(
                                            child: Text(
                                              searchMusicTale[index]
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
                                            padding: EdgeInsets.only(top: 5.0)
                                        ),
                                      ],
                                    ),
                                  ],
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
                    onTap: () {
                      var route = new MaterialPageRoute(
                        builder: (BuildContext context) =>
                        new MusicPlayer(musicDetailsJSON: searchMusicTale[index]),
                      );
                      Navigator.of(context).push(route);
                    }
                )
              ],
            );
          }
      );
    }
  }

  Widget _pushSearchAudioTale() {
    if(searchTale.length <= 0){
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
          itemCount: searchTale == null
              ? 0
              : searchTale.length,
          // ignore: missing_return
          itemBuilder: (BuildContext context, int index) {
            var id = searchTale[index].id;
            String imageURL = 'URL';
            bool checkSave = false;
            var sizeConvert = filesize(int.parse(searchTale[index].size));

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

            return Column(
              children: <Widget>[
               ListTile(
                    title: new Card(
                      elevation: 1.0,
                      child: new Container(
                        padding: EdgeInsets.all(5.0),
                        margin: EdgeInsets.all(5.0),
                        child: Column(
                          children: <Widget>[
                            CachedNetworkImage(
                              imageUrl: (Platform.isIOS && searchTale[index].iosImage == '1')
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
                                              searchTale[index]
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
                                            padding: EdgeInsets.all(1.0)
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Padding(
                                            child: Text(
                                              searchTale[index]
                                                  .author,
                                              textAlign: TextAlign
                                                  .right,
                                              style: (TextStyle(
                                                fontSize: fontSize,
                                                color: Colors
                                                    .lightBlueAccent,
                                                fontStyle: FontStyle
                                                    .italic,
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
                                              searchTale[index]
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
                                            padding: EdgeInsets.only(top: 5.0)
                                        ),
                                      ],
                                    ),
                                  ],
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
                    onTap: () {
                      var route = new MaterialPageRoute(
                        builder: (BuildContext context) =>
                        new AudioTalePlayer(audioTaleDetailsJSON: searchTale[index]),
                      );
                      Navigator.of(context).push(route);
                    }
                )
              ],
            );
          }
      );
    }
  }

  Widget _pushSearchFilmstrip() {
    if(searchFilmstripTale.length <= 0){
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
          itemCount: searchFilmstripTale == null
              ? 0
              : searchFilmstripTale.length,
          // ignore: missing_return
          itemBuilder: (BuildContext context, int index) {
            var id = searchFilmstripTale[index].id;
            String imageURL = 'URL';
            var sizeConvert = filesize(int.parse(searchFilmstripTale[index].size));

            return Column(
              children: <Widget>[
               ListTile(
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
                                                  searchFilmstripTale[index]
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
                                                padding: EdgeInsets.all(1.0)
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                                child: Text(
                                                  searchFilmstripTale[index]
                                                      .author,
                                                  textAlign: TextAlign
                                                      .right,
                                                  style: (TextStyle(
                                                    fontSize: fontSize,
                                                    color: Colors
                                                        .lightBlueAccent,
                                                    fontStyle: FontStyle
                                                        .italic,
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
                                                  searchFilmstripTale[index]
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
                                                padding: EdgeInsets.only(top: 5.0)
                                            ),
                                          ],
                                        ),
                                      ],
                                  ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Padding(
                                      child:Text(sizeConvert,
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
                    onTap: () {}
               )
              ],
            );
          }
      );
    }
  }

  Widget _pushSearchCartoons() {
    if(searchCartoonTale.length <= 0){
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
          itemCount: searchCartoonTale == null
              ? 0
              : searchCartoonTale.length,
          // ignore: missing_return
          itemBuilder: (BuildContext context, int index) {
            var id = searchCartoonTale[index].id;
            String imageURL = 'URL';

            return Column(
              children: <Widget>[
                ListTile(
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
                                                  searchCartoonTale[index]
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
                                                padding: EdgeInsets.all(1.0)
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                                child: Text(
                                                  searchCartoonTale[index]
                                                      .author,
                                                  textAlign: TextAlign
                                                      .right,
                                                  style: (TextStyle(
                                                    fontSize: fontSize,
                                                    color: Colors
                                                        .lightBlueAccent,
                                                    fontStyle: FontStyle
                                                        .italic,
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
                                                  searchCartoonTale[index]
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
                                                padding: EdgeInsets.only(top: 5.0)
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Container(
                                                    margin: EdgeInsets
                                                        .only(
                                                        left: 90.0
                                                    )
                                                ),
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
                    onTap: () {
                      void playYoutubeVideoIdEditAuto() {
                        FlutterYoutube.onVideoEnded.listen((onData) {});
                        FlutterYoutube.playYoutubeVideoById(
                            apiKey: "<API_KEY>",
                            videoId: searchCartoonTale[index].url,
                            autoPlay: true);
                      }
                      return playYoutubeVideoIdEditAuto();
                    }
                    )
              ],
            );
          }
      );
    }
  }

  Widget _pushSearchFilms() {
    if(searchFilmTale.length <= 0){
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
          itemCount: searchFilmTale == null
              ? 0
              : searchFilmTale.length,
          // ignore: missing_return
          itemBuilder: (BuildContext context, int index) {
            var id = searchFilmTale[index].id;
            String imageURL = 'URL';
            return Column(children: <Widget>[
                ListTile(
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
                                                  searchFilmTale[index]
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
                                                padding: EdgeInsets.all(1.0)
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                                child: Text(
                                                  searchFilmTale[index]
                                                      .author,
                                                  textAlign: TextAlign
                                                      .right,
                                                  style: (TextStyle(
                                                    fontSize: fontSize,
                                                    color: Colors
                                                        .lightBlueAccent,
                                                    fontStyle: FontStyle
                                                        .italic,
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
                                                  searchFilmTale[index]
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
                                                padding: EdgeInsets.only(top: 5.0)
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Container(
                                                    margin: EdgeInsets
                                                        .only(
                                                        left: 90.0
                                                    )
                                                ),
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
                    onTap: () {
                      void playYoutubeVideoIdEditAuto() {
                        FlutterYoutube.onVideoEnded.listen((onData) {});
                        FlutterYoutube.playYoutubeVideoById(
                            apiKey: "<API_KEY>",
                            videoId: searchFilmTale[index].url,
                            autoPlay: true);
                      }
                      return playYoutubeVideoIdEditAuto();
                    }
                    )
              ],
            );
          }
      );
    }
  }
}