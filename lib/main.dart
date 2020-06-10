import 'dart:io';

import 'package:audiotales/widgets/cartoons/cartoons.dart';
import 'package:audiotales/widgets/films/films.dart';
import 'package:audiotales/widgets/filmstrips/filmstrips.dart';
import 'package:audiotales/widgets/search/searchPage.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audiotales/widgets/audioTales/audioTales.dart';
import 'package:audiotales/widgets/music/music.dart';
import 'package:audiotales/widgets/texts/texts.dart';
import 'package:audiotales/widgets/favorites/favorites.dart';
import 'package:audiotales/widgets/playlists/playlistPage.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audiotales/modelJSON/globalData.dart';

import 'modelJSON/admob.dart';

RateMyApp _rateMyApp = RateMyApp();

BannerAd _bannerAd;

BannerAd myBanner() {
  _bannerAd = BannerAd(
      adUnitId: getBannerAdUnitId(),
      size: AdSize.smartBanner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.loaded) {
          _bannerAd.show(anchorOffset: 0.0, anchorType: AnchorType.bottom);
          paddingBanner = 86.0;
        } else if(event == MobileAdEvent.failedToLoad){
          paddingBanner = 0.0;
          main();
        }
      })
    ..load();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _rateMyApp.init().then((_) {
    runApp(new MaterialApp(
      initialRoute: '/audioTale',
      debugShowCheckedModeBanner: false,
      builder: (context, widget) {
        myBanner();
        _loadData();
        _loadDataArchive();
        return new Padding(
          child: widget,
          padding: new EdgeInsets.only(bottom: paddingBanner),
        );
      },
      routes: {
        '/audioTale':(BuildContext context) => AudioTalePage(),
        '/music':(BuildContext context) => MusicPage(),
        '/filmstrips':(BuildContext context) => Filmstrips(),
        '/texts':(BuildContext context) => Texts(),
        '/favorite':(BuildContext context) => Favorites(),
        '/cartoons':(BuildContext context) => Cartoons(),
        '/films':(BuildContext context) => Films(),
        '/audioPlaylist':(BuildContext context) => PlaylistPage(),
        '/search':(BuildContext context) => SearchPage(),
      },
    ));
    _rateMyApp.conditions.forEach((condition) {
      if (condition is DebuggableCondition) {
      }
    });
  });
}

void _loadData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  audioTaleList = prefs.getStringList('audioTaleList');
  if(audioTaleList == null) {
    audioTaleList = [];
  }
}

void _loadDataArchive() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  filmstripList = prefs.getStringList('filmstripList');
  if(filmstripList == null) {
    filmstripList = [];
  }
}

class NavDrawer extends StatelessWidget {

  Future<void> share() async {
    await FlutterShare.share(
      title: 'Приложение "Сказки"',
      text: 'Привет, Переходи и загружай наше приложение: "Сказки", ждем тебя!<3',
      linkUrl: (Platform.isIOS)
          ? 'https://apps.apple.com/ua/app/%D0%B0%D1%83%D0%B4%D0%B8%D0%BE%D1%81%D0%BA%D0%B0%D0%B7%D0%BA%D0%B8-%D0%B8-%D0%B4%D0%B5%D1%82%D1%81%D0%BA%D0%B0%D1%8F-%D0%BC%D1%83%D0%B7%D1%8B%D0%BA%D0%B0/id1512361026?l=ru'
          :  'https://play.google.com/store/apps/details?id=best.audio.tales.and.filmstrips.for.kids',
    );
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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.lightBlue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.headset),
            title: Text('Аудиосказки'),
            subtitle: Text('количество: ' + countAudiotale.toString()),
            onTap: () => {
              Navigator.pushNamed(context, '/audioTale')},
          ),
          ListTile(
            leading: Icon(Icons.music_note),
            title: Text('Музыка'),
            subtitle: Text('количество: ' + countMusic.toString()),
            onTap: () => {Navigator.pushNamed(context, '/music')},
          ),
          ListTile(
            leading: Icon(Icons.picture_in_picture),
            title: Text('Диафильмы'),
            subtitle: Text('Количество: ' + countFilmstrip.toString()),
            onTap: () => {Navigator.pushNamed(context, '/filmstrips')},
          ),
          ListTile(
            leading: Icon(Icons.local_movies),
            title: Text('Мультики'),
            subtitle: Text('количество: ' + countCartoon.toString()),
            onTap: () => {Navigator.pushNamed(context, '/cartoons')},
          ),
          ListTile(
            leading: Icon(Icons.videocam),
            title: Text('Фильмы'),
            subtitle: Text('количество: ' + countFilm.toString()),
            onTap: () => {Navigator.pushNamed(context, '/films')},
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Тексты'),
            subtitle: Text('количество: ' + countText.toString()),
            onTap: () => {Navigator.pushNamed(context, '/texts')},
          ),
          new Divider(),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Любимое'),
            onTap: () => {Navigator.pushNamed(context, '/favorite')},
          ),
          ListTile(
            leading: Icon(Icons.queue_music),
            title: Text('Плейлист'),
            onTap: () => {
              _loadPlaylist(),
              Navigator.pushNamed(context, '/audioPlaylist')
            },
          ),
          ListTile(
            leading: Icon(Icons.search),
            title: Text('Поиск'),
            onTap: () => {Navigator.pushNamed(context, '/search')},
          ),
          new Divider(),
          ListTile(
            leading: Icon(Icons.thumb_up),
            title: Text('Оставить отзыв'),
            onTap: () => _rateMyApp.showRateDialog(context),
          ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Отправить'),
            onTap: () => share(),
          ),
          new Divider(),
          Text('Build version 1.1.9(19)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.0,
            ),
            )
        ],
      ),
    );
  }
}
