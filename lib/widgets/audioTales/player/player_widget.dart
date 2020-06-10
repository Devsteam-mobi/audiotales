import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:audiotales/modelJSON/globalData.dart';
import 'package:audiotales/modelJSON/taleInf.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../audioTales.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class PlayerWidget extends StatefulWidget {
  final String url;
  AudioTaleDetailsJSON audioTaleDetailsJSON;
  bool autoPlay;

  PlayerWidget({this.url, this.autoPlay, this.audioTaleDetailsJSON});

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState(url, autoPlay);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  //audio player
  String url;
  bool autoPlay;
  Duration _duration;
  Duration _position;

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;

  //Timer
  int hour = 0;
  int min = 0;
  int sec = 0;
  bool startT = true;
  bool stopT = true;
  int timeForTimer = 0;
  bool checkTimer = true;
  String timeToDisplay = "";

  //load json
  File jsonFile;
  Directory dir;
  String fileName = "favoriteAudioTale.json";
  bool fileExists = false;

  bool checkFavor = false;

  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';
  get _durationFull => _durationText.toString()?.split('0:')?.last ?? '';
  get _positionFull => _positionText?.toString()?.split('0:')?.last ?? '';

  _PlayerWidgetState(this.url, this.autoPlay);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    autoPlayAfterDownload();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists){
        if(jsonFile.readAsStringSync().isNotEmpty) {
          favoriteDataAudioTale = json.decode(jsonFile.readAsStringSync());
          favoriteDataAudioTale =
              favoriteDataAudioTale.map((fav) =>
              new AudioTaleDetailsJSON
                  .fromJson(fav)).toList();
        }
      } else {
        createFile(dir, fileName);
      }
      });
    checkFav();
  }

//checking exists audio in favorite JSON
  void checkFav() {
    if (favoriteDataAudioTale.length > 0 && checkFavor == false) {
      for (int i = 0; i < favoriteDataAudioTale.length; i++) {
        if (favoriteDataAudioTale[i].name == widget.audioTaleDetailsJSON.name) {
          checkFavor = true;
        }
      }
    }
  }

  void createFile(Directory dir, String fileName) {
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    fileExists = true;
  }
  void autoPlayAfterDownload() {
    if (autoPlay == true && autoPlay != null) {
      _play();
    }
  }

  void startTimer (){
    if (!mounted) return;
    setState(() {
      startT = false;
      stopT = false;
    });
    timeForTimer = ((hour * 60 * 60) + (min * 60) + sec);
    Timer.periodic(
        Duration(
          seconds: 1,
        ), (Timer t){
      if (!mounted) return;
        setState(() {
          if (timeForTimer < 1 || checkTimer == false) {
            t.cancel();
            checkTimer = true;
            timeToDisplay = "";
            startT = true;
            stopT = true;
            _stop();
            Navigator.of(context).pop();
          } else if (timeForTimer < 60) {
            timeToDisplay = timeForTimer.toString();
            timeForTimer = timeForTimer - 1;
          } else if (timeForTimer < 3600) {
            int m = timeForTimer ~/ 60;
            int s = timeForTimer - (60 * m);
            timeToDisplay = m.toString() + ":" + s.toString();
            timeForTimer = timeForTimer - 1;
          } else {
            int h = timeForTimer ~/ 3600;
            int t = timeForTimer - (3600 * h);
            int m = t ~/ 60;
            int s = t - (60 * m);
            timeToDisplay =
                h.toString() + ":" + m.toString() + ":" + s.toString();
            timeForTimer = timeForTimer - 1;
          }
        });
    });
    Navigator.of(context).pop();
  }

  void stopTimer (){
    setState(() {
      startT = true;
      stopT = true;
      checkTimer = false;
    });
  }

  void deleteFromPlaylist() {
    for (int i = 0; i <= audioTalePlaylist.length; i++) {
      if (audioTalePlaylist.length > 0) {
        if (audioTalePlaylist[i] == url) {
          audioTalePlaylist.remove(url);
          break;
        }
      }
    }
  }
  void _removeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("audioTaleList", audioTaleList);
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
        final dir = Directory(url);
        dir.deleteSync(recursive: true);
        audioTaleList.remove(url);
        deleteFromPlaylist();
        _stop();
        url = null;
        var route = new MaterialPageRoute(
          builder: (BuildContext context) =>
          new AudioTalePage(),
        );
        Navigator.of(context).push(route);
        _removeData();
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

  _playBackRate(BuildContext context) {

    Widget cancelButton = FlatButton(
      child: Text("Отмена"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );

    Widget rate = FlatButton(
      child: Text("0.5"),
      onPressed:  () {
        setState(() {
          playback = 0.5;
          _audioPlayer.setPlaybackRate(playbackRate: playback);
          Navigator.of(context).pop();
        });
      },
    );
    Widget rate1 = FlatButton(
      child: Text("1.0"),
      onPressed:  () {
        setState(() {
          playback = 1.0;
          _audioPlayer.setPlaybackRate(playbackRate: playback);
          Navigator.of(context).pop();
        });
      },
    );
    Widget rate15 = FlatButton(
      child: Text("1.5"),
      onPressed:  () {
        setState(() {
          playback = 1.5;
          _audioPlayer.setPlaybackRate(playbackRate: playback);
          Navigator.of(context).pop();
        });
      },
    );
    Widget rate2 = FlatButton(
      child: Text("2.0"),
      onPressed:  () {
        setState(() {
          playback = 2.0;
          _audioPlayer.setPlaybackRate(playbackRate: playback);
          Navigator.of(context).pop();
        });
      },
    );
    Widget rate25 = FlatButton(
      child: Text("2.5"),
      onPressed:  () {
        setState(() {
          playback = 2.5;
          _audioPlayer.setPlaybackRate(playbackRate: playback);
          Navigator.of(context).pop();
        });
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Скорость возпроизведения"),
      content:
          SizedBox(
            width: 100,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Если вы хотите изменить скорость воспроизведение, выберете нужный вам рейт?"),
                  rate,
                  rate1,
                  rate15,
                  rate2,
                  rate25,
                ],
              )
          ),
      actions: [
        cancelButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  timerDialog(BuildContext context) {

    AlertDialog alert = AlertDialog(
      title: Text("Установить таймер"),
      content:
      SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(1.0
                          ),
                          child: Text('Час',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        NumberPicker.integer(
                          initialValue: hour,
                          minValue: 0,
                          maxValue: 23,
                          onChanged: (val){
                            setState(() {
                              hour = val;
                            });
                          },
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(1.0
                          ),
                          child: Text('Мин',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        NumberPicker.integer(
                          initialValue: min,
                          minValue: 0,
                          maxValue: 59,
                          listViewWidth: 60.0,
                          onChanged: (val){
                            setState(() {
                              min = val;
                            });
                          },
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(1.0
                          ),
                          child: Text('Сек',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        NumberPicker.integer(
                          initialValue: sec,
                          minValue: 0,
                          maxValue: 59,
                          listViewWidth: 60.0,
                          onChanged: (val){
                            setState(() {
                              sec = val;
                            });
                          },
                        )
                      ],
                    ),
                  ],
                )
            ),
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: startT ? startTimer : null,
                    padding: EdgeInsets.only(
                    ),
                    color: Colors.green,
                    child: Text(
                      "Начать",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)
                    ),
                  ),
                  Wrap(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 25.0),
                      ),
                      RaisedButton(
                        onPressed: stopT ? null : stopTimer,
                        padding: EdgeInsets.symmetric(
                        ),
                        color: Colors.red,
                        child: Text("Остановить",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ),),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void choiceAction(int choice){
    if(choice == 1){
      _playBackRate(context);
    }else if(choice == 2){
      deleteDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var audioId = widget.audioTaleDetailsJSON.id;

    var widgetAudioTale = widget.audioTaleDetailsJSON;
    if (_audioPlayerState == AudioPlayerState.COMPLETED) {
      _stop();
      if (checkRepeat == true) {
        _play();
      }
    }

    Future<void> _share() async {
      await FlutterShare.share(
        title: 'Приложение "Сказки"',
        text: 'Привет, с тобой поделились адуиофайлом с нашего приложения',
        linkUrl: (Platform.isIOS)
            ? 'Аудио: URL \n'
            'Приложение: https://apps.apple.com/ua/app/%D0%B0%D1%83%D0%B4%D0%B8%D0%BE%D1%81%D0%BA%D0%B0%D0%B7%D0%BA%D0%B8-%D0%B8-%D0%B4%D0%B5%D1%82%D1%81%D0%BA%D0%B0%D1%8F-%D0%BC%D1%83%D0%B7%D1%8B%D0%BA%D0%B0/id1512361026?l=ru'
            :  'Аудио: URL \n'
            'Приложение: https://play.google.com/store/apps/details?id=best.audio.tales.and.filmstrips.for.kids',
      );
    }


    void writeToFile() {
      checkFav();
      if (fileExists && checkFavor == false) {
        favoriteDataAudioTale.add(widgetAudioTale);
        jsonFile.writeAsStringSync(json.encode(favoriteDataAudioTale));
      } else if(checkFavor == true){
        favoriteDataAudioTale.removeWhere((item) => item.id == widgetAudioTale.id);
        jsonFile.writeAsStringSync(json.encode(favoriteDataAudioTale));
      }
      favoriteDataAudioTale = json.decode(jsonFile.readAsStringSync());
      favoriteDataAudioTale = favoriteDataAudioTale.map((fav) => new AudioTaleDetailsJSON.fromJson(fav)).toList();
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Stack(
          children: [
            Slider(
              onChanged: (v) {
                final position = v * _duration.inMilliseconds;
                audioPlayer
                    .seek(Duration(milliseconds: position.round()));
              },
              value: (_position != null &&
                  _duration != null &&
                  _position.inMilliseconds > 0 &&
                  _position.inMilliseconds < _duration.inMilliseconds)
                  ? _position.inMilliseconds / _duration.inMilliseconds
                  : 0.0,
            ),
          ],
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _position != null
                    ? '${_positionFull ?? ''}'
                    : _duration != null
                    ? _durationFull
                    : '00:00',
                style: TextStyle(fontSize: 12.0,),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _position != null
                    ? '${_durationFull ?? ''}'
                    : _duration != null ? _durationFull
                    : '${widget.audioTaleDetailsJSON.duration}',
                style: TextStyle(fontSize: 12.0,),
              ),
            ),
          ],),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Column(children: [
                MaterialButton(
                    padding: EdgeInsets.all(8.0),
                    elevation: 10.0,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.lightBlue
                      ),
                      child: SizedBox(
                        width: 110.0,
                        height: 40.0,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Отправить'),
                        ),
                      ),
                    ),
                    onPressed:(){
                      _share();
                    }
                ),
                PopupMenuButton<int>(
                  onSelected: choiceAction,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text(
                        "Изменить скорость воспроизведения",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w700),
                      ),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text(
                        "Удалить аудиозапись",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                  child: Container(
                    height: 40,
                    width: 110,
                    decoration: BoxDecoration(
                        color: Colors.lightBlue
                    ),
                    child: Center(
                      child: Text(
                        'Управление',
                        style: TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
                ],
              )
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: MaterialButton(
                  padding: EdgeInsets.all(8.0),
                  elevation: 10.0,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: isPlaying ? AssetImage('assets/logo/buttonPause.png'): AssetImage('assets/logo/playButtonTrue.png'),
                          fit: BoxFit.fill),
                    ),
                    child: SizedBox(
                      width: 80.0,
                      height: 80.0,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(''),
                      ),
                    ),
                  ),
                  onPressed: isPlaying
                      ? () => _pause()
                      : () => _play()
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Column(children: <Widget>[
                MaterialButton(
                    padding: EdgeInsets.all(8.0),
                    elevation: 10.0,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.lightBlue
                      ),
                      child: SizedBox(
                        width: 110.0,
                        height: 40.0,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(timeToDisplay != "" ? timeToDisplay : 'Таймер'),
                        ),
                      ),
                    ),
                    onPressed:(){
                      timerDialog(context);
                    }
                ),
                MaterialButton(
                  padding: EdgeInsets.all(8.0),
                  elevation: 10.0,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.lightBlue
                    ),
                    child: SizedBox(
                      width: 110.0,
                      height: 40.0,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text((checkFavor == false || favoriteDataAudioTale == null)
                            ? "Добавить в любимое"
                            : "Удалить из любимого",
                          textAlign: TextAlign.center,),
                      ),
                    ),
                  ),
                  onPressed:() => setState(() => {
                    checkFav(),
                    if(checkFavor){
                      writeToFile(),
                      checkFavor = false,
                      Fluttertoast.showToast(
                          msg: "Удалено из любимых!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.redAccent,
                          textColor: Colors.white,
                          fontSize: 20.0
                      ),
                    } else if (checkFavor == false || favoriteDataAudioTale == null) {
                      widgetAudioTale.favorite = true,
                      writeToFile(),
                      checkFavor = true,
                      Fluttertoast.showToast(
                          msg: "Добавлено в любимое!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.lightBlueAccent,
                          textColor: Colors.white,
                          fontSize: 20.0
                      ),
                    }
                  },
                  ),
                ),
              ],),
            ),
          ],
        ),
              Align(
                alignment: Alignment.bottomRight,
                child:  IconButton(
                  onPressed: _checkRepeat,
                  iconSize: 45.0,
                  icon: checkRepeat == false
                      ? Icon(Icons.repeat)
                      : Icon(Icons.repeat_one),
                ),
          ),
      ],
    );
  }

  void _checkRepeat(){
    if (checkRepeat == false){
      checkRepeat = true;
      Fluttertoast.showToast(
          msg: "Зацикливание этого трека включено",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black45,
          textColor: Colors.white,
          fontSize: 15.0
      );
    } else {
      checkRepeat = false;
      Fluttertoast.showToast(
          msg: "Зацикливание этого трека выключено",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black45,
          textColor: Colors.white,
          fontSize: 15.0
      );
    }
  }

  void _initAudioPlayer() {
    _audioPlayer = audioPlayerTest;
    _audioPlayer.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() {
        _duration = duration;
      });

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        _audioPlayer.startHeadlessService();
        _audioPlayer.setNotification(
            title: widget.audioTaleDetailsJSON.name,
            artist: widget.audioTaleDetailsJSON.author,
            imageUrl: 'URL',
            forwardSkipInterval: const Duration(seconds: 30), // default is 30s
            backwardSkipInterval: const Duration(seconds: 30), // default is 30s
            duration: duration,
            elapsedTime: Duration(seconds: 0));
      }
    });

    _audioPlayer.onAudioPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() {
        _position = position;
      });
    });

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
          if (!mounted) return;
          _onComplete();
          setState(() {
            _position = _duration;
          });
        });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      if (!mounted) return;
      setState(() {
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
      });
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
      });
    });
  }

  Future<void> _play() async {
    print(playback);
    final playPosition = (_position != null &&
        _duration != null &&
        _position.inMilliseconds > 0 &&
        _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(url, position: playPosition);
    if (result == 1) setState(() => playerState = PlayerState.playing);

    if(playback == null) {
      _audioPlayer.setPlaybackRate(playbackRate: 1.0);
    } else {
      _audioPlayer.setPlaybackRate(playbackRate: playback);
    }
    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => playerState = PlayerState.paused);

    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        playerState = PlayerState.stopped;
        _position = Duration();
      });
    }
    return result;
  }
  void _onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }
}