import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audiotales/modelJSON/globalData.dart';
import 'package:audiotales/widgets/audioTales/player/player_widget.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';


class AudioPlaylist extends StatefulWidget {
  final List<String> urls;


  AudioPlaylist({this.urls});

  @override
  State<StatefulWidget> createState() {
    return _AudioPlaylistState(urls);
  }
}

class _AudioPlaylistState extends State<AudioPlaylist> {

  List<String> urls;

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
  String timeToDisplay = "";
  bool checkTimer = true;

  bool checkFavor = false;

  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';
  get _durationFull => _durationText.toString()?.split('0:')?.last ?? '';
  get _positionFull => _positionText?.toString()?.split('0:')?.last ?? '';


  _AudioPlaylistState(this.urls);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void startTimer (){
    setState(() {
      startT = false;
      stopT = false;
    });
    timeForTimer = ((hour * 60 * 60) + (min * 60) + sec);
    Timer.periodic(Duration(
      seconds: 1,
    ), (Timer t){
      if(mounted) {
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
      }
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

  timerDialog(BuildContext context) {

    AlertDialog alert = AlertDialog(
      title: Text("Удалить аудиозапись"),
      content:
      Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 10.0,
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
                          padding: EdgeInsets.only(bottom: 10.0,
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
                          padding: EdgeInsets.only(bottom: 10.0,
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
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: startT ? startTimer : null,
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 10.0,
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
                  RaisedButton(
                    onPressed: stopT ? null : stopTimer,
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 10.0,
                    ),
                    color: Colors.red,
                    child: Text("Стоп",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),),
                    shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)
                    ),
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


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(),
          child: Row(
            children: <Widget>[
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              Align(
                alignment: Alignment.centerLeft,
                child: MaterialButton(
                    padding: EdgeInsets.all(8.0),
                    elevation: 10.0,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/logo/skipPreviously.png'),
                            fit: BoxFit.fill),
                      ),
                      child: SizedBox(
                        width: 40.0,
                        height: 40.0,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(''),
                        ),
                      ),
                    ),
                    onPressed:() => _skipPrev()
                ),
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
                        width: 40.0,
                        height: 40.0,
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
                alignment: Alignment.centerRight,
                child: MaterialButton(
                    padding: EdgeInsets.all(8.0),
                    elevation: 10.0,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/logo/skipNext.png'),
                            fit: BoxFit.fill),
                      ),
                      child: SizedBox(
                        width: 40.0,
                        height: 40.0,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(''),
                        ),
                      ),
                    ),
                    onPressed: () => _skipNext()
                ),
              ),
            ],
          ),
        ),
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
                    : _duration != null ? _durationFull
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
                    : '',
                style: TextStyle(fontSize: 12.0,),
              ),
            ),
          ],),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = audioPlayerTest;
    _audioPlayer.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() {
        _duration = duration;
      });
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

  int i = 0;
  Future<int> _play() async {
    final playPosition = (_position != null &&
        _duration != null &&
        _position.inMilliseconds > 0 &&
        _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(urls[i], position: playPosition);
    if (result == 1) setState(() => playerState = PlayerState.playing);

    // default playback rate is 1.0
    // this should be called after _audioPlayer.play() or _audioPlayer.resume()
    // this can also be called everytime the user wants to change playback rate in the UI
    _audioPlayer.setPlaybackRate(playbackRate: 1.0);

    return result;
  }
  bool stopped = false;
  Future<int> _skipNext() async {
    _stop();
    if (i < urls.length) {
      i++;
      if (i == urls.length) {
        i--;
        _stop();
      }
      final result = await _audioPlayer.play(urls[i]);
      if (result == 1) setState(() => playerState = PlayerState.playing);
      return result;
    }
  }

  Future<int> _skipPrev() async {
    if (i > 0) {
      i--;
      final result = await _audioPlayer.play(urls[i]);
      if (result == 1) setState(() => playerState = PlayerState.playing);
      return result;
    }
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