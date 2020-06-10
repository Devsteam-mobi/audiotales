import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audiotales/widgets/audioTales/player/player_widget.dart';

//Audio player
PlayerState playerState = PlayerState.stopped;

get isPlaying => playerState == PlayerState.playing;

AudioPlayer audioPlayer = AudioPlayer();
AudioPlayer get audioPlayerTest => audioPlayer;

Future<int> stop() async {
  final result = await audioPlayer.stop();
  if (result == 1) {
      playerState = PlayerState.stopped;
  }
  return result;
}

double playback;

//Path to audio
List<String> audioTaleList = [];

//Path to archive
List<String> filmstripList = [];

//playlistPath
List<String> audioTalePlaylist = [];

//fav
List<dynamic> favoriteDataAudioTale = [];
List<dynamic> favoriteDataText = [];
List<dynamic> favoriteDataMusic = [];
List<dynamic> favoriteDataFilmstrip = [];

//repeatModeCheck
bool checkRepeat = false;

//fontSize
double fontSize = 20.0;

//control ios_content
List<String> iosDisable = [
  '55',
  '69',
  '504',
];

//imageDefault
String imageUrlDefAudio = 'assets/logo/defaultAudio.jpg';
String imageUrlDefVideo = 'assets/logo/defaultVideo.jpg';
String imageUrlDefText = 'assets/logo/defaultText.jpg';

double imageSets = 100.0;
double imageItems = 200.0;

var countFilmstrip = 261;
var countAudiotale = 1648;
var countFilm = 27;
var countCartoon = 61;
var countText = 6890;
var countMusic = 1065;

var paddingBanner = 0.0;

bool isOpenDrawerOnStart = false;