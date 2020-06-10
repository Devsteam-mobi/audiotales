import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audiotales/modelJSON/admob.dart';
import 'package:audiotales/modelJSON/globalData.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'player_widget.dart';
import 'package:http/http.dart' as http;
import 'package:audiotales/modelJSON/taleInf.dart';

class AudioTalePlayer extends StatefulWidget {
  final AudioTaleDetailsJSON audioTaleDetailsJSON;

  AudioTalePlayer({Key key, this.audioTaleDetailsJSON}) : super(key: key);


  @override
  _AudioTalePlayerState createState() => _AudioTalePlayerState();
}

class _AudioTalePlayerState extends State<AudioTalePlayer> {
  String localFilePath;
  File jsonFile;
  Directory dir;
  String fileName = "favoriteAudioTale.json";
  bool fileExists = false;
  bool checkFavor = false;
  bool autoPlay;

  @override
  void initState() {
    super.initState();
    _checkPath();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists){
        favoriteDataAudioTale = json.decode(jsonFile.readAsStringSync());
        favoriteDataAudioTale = favoriteDataAudioTale.map((fav) => new AudioTaleDetailsJSON.fromJson(fav)).toList();
      }
     });
    }

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("audioTaleList", audioTaleList);
  _loadData();
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    audioTaleList = prefs.getStringList('audioTaleList');
  }

  void _savePlaylist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("audioPlaylist", audioTalePlaylist);

    _loadPlaylist();
  }

  void _loadPlaylist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    audioTalePlaylist = prefs.getStringList('audioPlaylist');
  }


  Widget _tab(List<Widget> children) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: children
              .map((w) => Container(child: w, padding: EdgeInsets.all(6.0)))
              .toList(),
        ),
      ),
    );
  }

  //checking exist file in phone
  void _checkPath() {
    var id = widget.audioTaleDetailsJSON.id;
    if (audioTaleList != null) {
      for (int i = 0; i < audioTaleList.length; i++) {
        var count = File(audioTaleList[i]).path
            .split('/')
            .last;
        if (count == '$id.mp3') {
          localFilePath = audioTaleList[i].toString();
          break;
        } else {
          localFilePath = null;
        }
      }
    } else
      localFilePath = null;
  }

  //load local File from phone and main screen
  Widget localFile() {
    var id = widget.audioTaleDetailsJSON.id;
    var dur = widget.audioTaleDetailsJSON.duration;
    double _value = 0.0;
    void _setValue(double value) => setState(() => _value = value);
    String imageURL = 'URL';

    return _tab([
      Text(widget.audioTaleDetailsJSON.name,
        style: new TextStyle(
          fontSize: 30.0,
          fontStyle: FontStyle.italic,
        ),
      textAlign: TextAlign.center,),
      Card(
        elevation: 50,
       child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 8,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CachedNetworkImage(
          imageUrl: (Platform.isIOS && widget.audioTaleDetailsJSON.iosImage == '1')
              ? imageUrlDefAudio
              :imageURL,
          placeholder: (context, url) => new CircularProgressIndicator(),
          errorWidget: (context, url, error) => new Image.asset(
            imageUrlDefAudio,
          ),
        ),
       ),
      ),
      localFilePath == null ? Column(
    children: <Widget>[
        Stack(
          children: [
            new Slider(value: _value, onChanged: _setValue)
          ],
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('00:00',
                style: TextStyle(fontSize: 12.0,),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text('$dur',style: TextStyle(fontSize: 12.0,),
              ),
            ),
          ],
        ),
        Center(
          child: MaterialButton(
        padding: EdgeInsets.all(8.0),
          elevation: 10.0,
              child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/logo/playButtonFalse.png'),
                  fit: BoxFit.fill),
            ),
                child: SizedBox(
                  width: 80.0,
                  height: 80.0,
                  child: Align(
                      alignment: Alignment.center,
                      child:_total > 0 ? Text(((_received / _total) * 100).toStringAsFixed(0) + "%", style: TextStyle(fontSize: 20,color: Colors.black),):
                  Text(''),),
                ),
              ),
        onPressed: () {
          autoPlay = true;
          _loadFile();
          },
         ),
        ),
    ],
      )
          : PlayerWidget(url: localFilePath, autoPlay: autoPlay, audioTaleDetailsJSON: widget.audioTaleDetailsJSON),
    ]);
  }

// download file on phone
  int _total = 0, _received = 0;
  http.StreamedResponse _response;
  File _file;
  List<int> _bytes = [];

  Future<void> _loadFile() async {
    var audioId = widget.audioTaleDetailsJSON.id;
    var playerURL = 'URL';
    _response = await http.Client().send(http.Request('GET', Uri.parse(playerURL)));
    _total = _response.contentLength;

    _response.stream.listen((value) {
      if(mounted) {
        setState(() {
          _bytes.addAll(value);
          _received += value.length;
        });
      }
    }).onDone(() async {
      final file = File("${(await getApplicationDocumentsDirectory()).path}/$audioId.mp3");
      await file.writeAsBytes(_bytes);
      if(mounted) {
        setState(() {
          _file = file;
          localFilePath = file.path;
          audioTaleList.add(localFilePath);
          _saveData();
        });
      }
      });
  }

  //checking and deleting audio from playlist
  void deleteFromPlaylist() {
    for (int i = 0; i <= audioTalePlaylist.length; i++) {
      if (audioTalePlaylist.length > 0) {
        if (audioTalePlaylist[i] == localFilePath) {
          audioTalePlaylist.remove(localFilePath);
          audioTalePlaylist.remove(localFilePath);
          _savePlaylist();
          break;
        }
      }
    }
  }

  //deleteAlertDialog
  deleteDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Отмена"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Удалить"),
      onPressed: () {
        deleteFromPlaylist();
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: "Запись удалена",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 10.0
        );
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Удалить аудиозапись"),
      content: Text("Данная аудиозапись уже присуствует в вашем плейлисте, вы хотите ее удалить?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  InterstitialAd _interstitialAd;

  Future<bool> _onWillPop() async {
    myInterstitial();
  }

  InterstitialAd myInterstitial() {
    _interstitialAd = InterstitialAd(
        adUnitId: getInterstitialAdUnitId(),
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          if (event == MobileAdEvent.loaded) {
            _interstitialAd.show(anchorType: AnchorType.bottom);
          }
          if (event == MobileAdEvent.opened || event == MobileAdEvent.clicked || event == MobileAdEvent.failedToLoad) {
            Navigator.of(context).pop(true);
          }
        })
      ..load();
  }

  @override
  Widget build(BuildContext context) {
    bool checkPlaylist = false;

    //check audio in playlist
    void check() {
      if (audioTalePlaylist.length > 0 && checkPlaylist == false) {
        for (int i = 0; i < audioTalePlaylist.length; i++) {
          if (audioTalePlaylist[i] == localFilePath) {
            checkPlaylist = true;
          }
        }
      }
    }
    return new WillPopScope(
        onWillPop: _onWillPop,
        child: DefaultTabController(
          length: 1,
          child: Scaffold(
            appBar: AppBar( actions: <Widget>[
              IconButton(
                icon: Icon(Icons.playlist_add),
                onPressed: () => setState(() => {
                  check(),
                if( localFilePath != null && checkPlaylist == false){
                    audioTalePlaylist.add(localFilePath),
                    _savePlaylist(),
                    checkPlaylist = true,
                    Fluttertoast.showToast(
                        msg: "Добавлено в ваш плейлист",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.lightBlueAccent,
                        textColor: Colors.white,
                        fontSize: 20.0
                    ),
                  } else if (localFilePath == null) {
                    Fluttertoast.showToast(
                    msg: "Установите аудиосказку",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 20.0
                ),
                  } else if (checkPlaylist == true){
                  deleteDialog(context),
                 },
                },
                ),
              ),
            ],
            ),
            body: ListView(
              children: [
                localFile(),
              ],
            ),
          ),
        ),
    );
  }
}
