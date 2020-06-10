import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audioTalesPlaylist.dart';
import 'package:audiotales/modelJSON/taleInf.dart';
import 'package:audiotales/modelJSON/globalData.dart';

class PlaylistPage extends StatefulWidget {
  final TaleInf taleInf;
  final AudioTaleDetailsJSON audioTaleDetailsJSON;

  PlaylistPage({Key key, this.taleInf, this.audioTaleDetailsJSON}) : super(key: key);


  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {

  @override
  void initState(){
    super.initState();
    _loadPlaylist();
  }

  void _loadPlaylist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    audioTalePlaylist = prefs.getStringList('audioPlaylist');
    if(audioTalePlaylist == null){
      audioTalePlaylist = [];
    }
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
        appBar: AppBar(
          title: Text('Плейлист'),
        ),
        body: Column(
          children: [
            Wrap(children: <Widget>[
              AudioPlaylist(urls: audioTalePlaylist),
            ]),
            Wrap(
              children: <Widget> [
                audioTalePlaylist == null ?
                Text("В очереди нету треков") :
                Text("У вас в очереди: " + audioTalePlaylist.length.toString()),
            ])
          ],
        ),
    );
  }
}