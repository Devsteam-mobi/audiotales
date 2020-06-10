import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:audiotales/modelJSON/globalData.dart';
import 'package:audiotales/widgets/audioTales/audioTales.dart';
import 'package:audiotales/widgets/audioTales/player/player_widget.dart';
import 'package:floating_action_row/floating_action_row.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audiotales/modelJSON/taleInf.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FilmstripArchive extends StatefulWidget {
final FilmstripDetailsJSON filmstripDetailsJSON;

  FilmstripArchive({Key key, this.filmstripDetailsJSON}) : super(key: key);

  @override
  FilmstripArchiveState createState() => FilmstripArchiveState();
}

class FilmstripArchiveState extends State<FilmstripArchive> {
  bool _downloading;

  List<String> _tempImages = [];
  List<String> _images = [];
  List<String> _texts = [];
  List<String> _musics = [];

  bool isEmptyMusic = false;
  bool isEmptyText = false;

  int _total = 0, _received = 0;
  http.StreamedResponse _response;
  File _file;
  List<int> _bytes = [];
  String localFilePath;

  File jsonFile;
  Directory dir;
  String fileName = "favoriteFilmstrip.json";
  bool fileExists = false;
  bool checkFavor = false;


  int photoIndex = 0;

  bool checkVisibility = true;
  bool checkMusic = true;

  @override
  void initState() {
    super.initState();
    _checkPath();
    _downloadZip();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists) {
        favoriteDataFilmstrip = json.decode(jsonFile.readAsStringSync());
        favoriteDataFilmstrip =
            favoriteDataFilmstrip.map((fav) => new FilmstripDetailsJSON.fromJson(fav))
                .toList();
      } else {
        createFile(dir, fileName);
      }
    });
    checkFav();
   }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _stop();
    super.dispose();
  }

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("filmstripList", filmstripList);
    _loadData();
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    filmstripList = prefs.getStringList('filmstripList');
  }

  void createFile(Directory dir, String fileName) {
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    fileExists = true;
  }

  void checkFav() {
    if (favoriteDataFilmstrip.length > 0 && checkFavor == false) {
      for (int i = 0; i < favoriteDataFilmstrip.length; i++) {
        if (favoriteDataFilmstrip[i].name == widget.filmstripDetailsJSON.name) {
          checkFavor = true;
        }
      }
    }
  }

  //checking exist file in phone
  void _checkPath() {
    var id = widget.filmstripDetailsJSON.id;
    if (filmstripList != null) {
      for (int i = 0; i < filmstripList.length; i++) {
        var count = File(filmstripList[i]).path
            .split('/')
            .last;
        if (count == '$id'+ '_m.zip' || count == '$id.zip') {
          localFilePath = filmstripList[i].toString();
          break;
        } else {
          localFilePath = null;
        }
      }
    } else
      localFilePath = null;
  }

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;

  AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer get audioPlayerTest => _audioPlayer;

  Future<int> _stop() async {
    final result = await audioPlayer.stop();
    if (result == 1) {
      playerState = PlayerState.stopped;
    }
    return result;
  }

  Future<int> _play(url) async {
    final result = await audioPlayer.play(url);
    if (result == 1) {
      playerState = PlayerState.playing;

      audioPlayer.setPlaybackRate(playbackRate: 1.0);

      return result;
    }
  }


  Future<void> _loadCurrentArchive() async {
    var archiveId = widget.filmstripDetailsJSON.id;
    var archive = 'URL';
    _response = await http.Client().send(http.Request('GET', Uri.parse(archive)));
    _total = _response.contentLength;
    if(_response.statusCode == 200){
      _response.stream.listen((value) {
        if (mounted) {
          setState(() {
            _bytes.addAll(value);
            _received += value.length;
          });
        }
      }).onDone(() async {
        final file = File(
            "${(await getApplicationDocumentsDirectory()).path}/$archiveId.zip");
        await file.writeAsBytes(_bytes);
        if (mounted) {
          setState(() {
            _file = file;
            localFilePath = file.path;
            _downloadZip();
            filmstripList.add(localFilePath);
            _saveData();
          });
        }
      });
    }
  }

  Future<void> _loadFile(url) async {
    var archiveId = widget.filmstripDetailsJSON.id;
    _response = await http.Client().send(http.Request('GET', Uri.parse(url)));
    _total = _response.contentLength;

    if (_response.statusCode == 410 || _response.statusCode == 404){
      _loadCurrentArchive();
    } else if(_response.statusCode == 200){
      _response.stream.listen((value) {
        if (mounted) {
          setState(() {
            _bytes.addAll(value);
            _received += value.length;
          });
        }
      }).onDone(() async {
        final file = File(
            "${(await getApplicationDocumentsDirectory()).path}/$archiveId" +
                "_m.zip");
        await file.writeAsBytes(_bytes);
        if (mounted) {
          setState(() {
            _file = file;
            localFilePath = file.path;
            filmstripList.add(localFilePath);
            _saveData();
            _downloadZip();
          });
        }
      });
    }
  }

  Future<void> _downloadZip() async {
    String archiveId = widget.filmstripDetailsJSON.id;
    var archiveUrl = 'URL';

    _images.clear();
    _tempImages.clear();

    if(localFilePath == null) {
      _downloading = false;
      _loadFile(archiveUrl);
    } else {
      _downloading = true;
      await unarchiveAndSave();
    }

    setState(() {
      for(int i = 0; i < _tempImages.length; i++) {
        for (int j = 0; j < _tempImages.length; j++) {
          bool imagesCheck = _tempImages[i].endsWith('/$j.jpg');
          bool textsCheck = _tempImages[i].endsWith('/$j.txt');
          bool musicsCheck = _tempImages[i].endsWith('/$j.mp3');

          if (imagesCheck == true) {
            _images.add(_tempImages[i]);
          } else if (textsCheck == true) {
            _texts.add(_tempImages[i]);
          } else if (musicsCheck == true) {
            _musics.add(_tempImages[i]);
          }
        }
        }
      checkList();
      if(_musics.isNotEmpty) {
        _play(_musics[photoIndex]);
      }
    });
  }

  unarchiveAndSave() async {
    var archiveId = widget.filmstripDetailsJSON.id;
    var archiveFile = File(localFilePath);

    var bytes = archiveFile.readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);
      for (var file in archive) {
        var fileName = '${(await getApplicationDocumentsDirectory()).path}/$archiveId/${file.name}';
        if (file.isFile) {
          var outFile = File(fileName);
          _tempImages.add(outFile.path.split('__MACOSX/').last);
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
        }
      }
    }

  void _previousImage() {
    setState(() {
      photoIndex = photoIndex > 0 ? photoIndex - 1 : 0;
      if(_musics.isNotEmpty && checkMusic == true) {
        _play(_musics[photoIndex]);
      }
    });
  }

  void _nextImage() {
    setState(() {
      photoIndex = photoIndex < _images.length - 1 ? photoIndex + 1 : photoIndex;
      if(_musics.isNotEmpty && checkMusic == true) {
        _play(_musics[photoIndex]);
      }
    });
  }

  void _onHorizontalDrag(DragEndDetails details) {
    if(details.primaryVelocity == 0) return;

    if (details.primaryVelocity.compareTo(0) == -1)
      _nextImage();
      else
      _previousImage();
  }

  buildList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Align(alignment: Alignment.center,
          child: Image.file(
            File(_images[photoIndex]),
            gaplessPlayback: true,
            fit: BoxFit.contain,
          ),
        ),
        Visibility(
          visible: checkVisibility,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _texts.length > 0
                ? Text(
              File(_texts[photoIndex]).readAsStringSync(),
              style: TextStyle(
                  color: Colors.white
              ),
            )
                : Center(),
          ),
        )
      ]);
  }

  deleteDialog(BuildContext context) {

    Widget cancelButton = FlatButton(
      child: Text("Отмена"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Удалить"),
      onPressed:  () {
        final dir = Directory(localFilePath);
        dir.deleteSync(recursive: true);
        filmstripList.remove(localFilePath);
        _stop();
        localFilePath = null;
        var route = new MaterialPageRoute(
          builder: (BuildContext context) =>
          new AudioTalePage(),
        );
        Navigator.of(context).push(route);
        _saveData();
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
      content: Text("Вы действительно хотите удалить аудиозапись?"),
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

  void checkList(){
    if(_musics.length <= 0){
      isEmptyMusic = true;
    }
    if(_texts.length <= 0){
      isEmptyText = true;
      print('teper text tyt false ' + isEmptyText.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var filmstripObject = widget.filmstripDetailsJSON;

    void writeToFile() {
      checkFav();
      if (fileExists && checkFavor == false) {
        favoriteDataFilmstrip.add(filmstripObject);
        jsonFile.writeAsStringSync(json.encode(favoriteDataFilmstrip));
      } else if(checkFavor == true){
        favoriteDataFilmstrip.removeWhere((item) => item.id == filmstripObject.id);
        jsonFile.writeAsStringSync(json.encode(favoriteDataFilmstrip));
      } else {
        createFile(dir, fileName);
      }
      favoriteDataFilmstrip = json.decode(jsonFile.readAsStringSync());
      favoriteDataFilmstrip = favoriteDataFilmstrip.map((fav) => new FilmstripDetailsJSON.fromJson(fav)).toList();
    }

    var children = List<Widget>();
    children.add(
      FloatingActionRowButton(
        icon:
        checkFavor == false
            ? Icon(Icons.favorite_border)
            : Icon(Icons.favorite, color: Colors.red),
        onTap: () {
          setState(() => {
            checkFav(),
            if(checkFavor){
              writeToFile(),
              checkFavor = false,
              Fluttertoast.showToast(
                  msg: "Удалено из любимых!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 20.0
              ),
            } else if (checkFavor == false || favoriteDataFilmstrip == null) {
              writeToFile(),
              checkFavor = true,
              Fluttertoast.showToast(
                  msg: "Добавлено в любимое!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.lightBlueAccent,
                  textColor: Colors.white,
                  fontSize: 20.0
              ),
            }
          });
        }
      ),
    );
    children.add(
      FloatingActionRowButton(
        icon: Icon(Icons.delete_forever),
        onTap: () {
          deleteDialog(context);
        },
      ),
    );
    children.add(
      FloatingActionRowButton(
        icon: Icon(
            (checkMusic && isEmptyMusic == false)
                ? Icons.volume_up
                : Icons.volume_off,
          color:
          isEmptyMusic == true
              ? Colors.grey
              : Colors.white),
        onTap: () {
          setState(() {
            if(isEmptyMusic == false) {
              if (checkMusic) {
                _stop();
                checkMusic = false;
              } else if (_musics.isNotEmpty) {
                _play(_musics[photoIndex]);
                checkMusic = true;
              }
            }
          });
        },
      ),
    );
    children.add(
      FloatingActionRowButton(
        icon: Icon(
            (checkVisibility && isEmptyText == false)
                ? Icons.remove_red_eye
                : Icons.visibility_off,
          color:
          isEmptyText == true
              ? Colors.grey
              : Colors.white,
        ),
        onTap: () {
          setState(() {
            if(isEmptyText == false) {
              if (checkVisibility)
                checkVisibility = false;
              else
                checkVisibility = true;
            }
          });
          },
      ),
    );
    children.add(
      FloatingActionRowButton(
        icon: Icon(Icons.refresh),
        onTap: () {
          setState(() {
            photoIndex = 0;
            if(_musics.isNotEmpty && checkMusic)
            _play(_musics[photoIndex]);
          });
        },
      ),
    );

    return GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) => _onHorizontalDrag(details),
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: _images.isNotEmpty
                ? Align(
              alignment: Alignment.centerRight,
              child: Text(
                (photoIndex + 1).toString() +'/' + _images.length.toString(),
                style: TextStyle(
                    color: Colors.white
                )
            ),
            )
                : Text(''),
            backgroundColor: Colors.black,
          ),
          body: Container(
                child: Center(
                  child:_images.length < 1
                      ? Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                          ),
                          Align(
                              alignment: Alignment.center,
                              child:_total > 0
                                  ? Text(
                                  'Идет загрузка... ' + ((_received / _total) * 100).toStringAsFixed(0) + "%",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white
                                  )
                              )
                                  : Text('')
                          )
                        ],)
                      )
                      : buildList(),
                ),
          ),
          floatingActionButton:
          Visibility(
            visible: _downloading,
          child: Padding(
            padding: EdgeInsets.only(
                top:100.0,
                left: 20.0
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: FloatingActionRow(
                children: children,
                color: Colors.black,
              ),
            ),
          ),)
        ),
    );
  }
}