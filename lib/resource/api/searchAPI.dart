import 'dart:convert';
import 'dart:io';

import 'package:audiotales/modelJSON/globalData.dart';
import 'package:audiotales/modelJSON/taleInf.dart';
import 'package:http/http.dart' as http;

class SearchAPI{
  static Future<List<AudioTaleDetailsJSON>> searchAudioTaleDetailsAPI() async{
    var response = await http.get('URL');

    if(response.statusCode == 200){
      List<AudioTaleDetailsJSON> searchAudioTaleDetailsURL = parsesAudio(response.body);
      for(int i = 0; i < searchAudioTaleDetailsURL.length; i++) {
        for (int j = 0; j < iosDisable.length; j++) {
          if (Platform.isIOS && searchAudioTaleDetailsURL[i].stId == iosDisable[j]) {
            searchAudioTaleDetailsURL.remove(searchAudioTaleDetailsURL[i]);
          }
        }
      }
      return searchAudioTaleDetailsURL;
    } else
      throw Exception('fail in load data');
  }
  static List<AudioTaleDetailsJSON> parsesAudio (String responseBody){
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<AudioTaleDetailsJSON>((json)=> AudioTaleDetailsJSON.fromJson(json)).toList();
  }

//Music

  static Future<List<MusicDetailsJSON>> searchMusicDetailsAPI() async{
    var response = await http.get('URL');

    if(response.statusCode == 200){
      List<MusicDetailsJSON> searchMusicDetailsURL = parsesMusic(response.body);
      for(int i = 0; i < searchMusicDetailsURL.length; i++) {
        for (int j = 0; j < iosDisable.length; j++) {
          if (Platform.isIOS && searchMusicDetailsURL[i].stId == iosDisable[j]) {
            searchMusicDetailsURL.remove(searchMusicDetailsURL[i]);
          }
        }
      }
      return searchMusicDetailsURL;
    } else
      throw Exception('fail in load data');
  }
  static List<MusicDetailsJSON> parsesMusic (String responseBody){
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<MusicDetailsJSON>((json)=> MusicDetailsJSON.fromJson(json)).toList();
  }

//Films

  static Future<List<FilmDetailsJSON>> searchFilmDetailsAPI() async{
    var response = await http.get('URL');

    if(response.statusCode == 200){
      List<FilmDetailsJSON> searchFilmDetailsURL = parsesFilms(response.body);
      return searchFilmDetailsURL;
    } else
      throw Exception('fail in load data');
  }
  static List<FilmDetailsJSON> parsesFilms (String responseBody){
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<FilmDetailsJSON>((json)=> FilmDetailsJSON.fromJson(json)).toList();
  }

//filmstrip

  static Future<List<FilmstripDetailsJSON>> searchFilmstripDetailsAPI() async{
    var response = await http.get('URL');

    if(response.statusCode == 200){
      List<FilmstripDetailsJSON> searchFilmstripDetailsURL = parsesFilmstrip(response.body);
      return searchFilmstripDetailsURL;
    } else
      throw Exception('fail in load data');
  }
  static List<FilmstripDetailsJSON> parsesFilmstrip (String responseBody){
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    var count = parsed
        .map<FilmstripDetailsJSON>((json)=> FilmstripDetailsJSON.fromJson(json)).toList();
    return count;
  }

//Cartoon

  static Future<List<CartoonDetailsJSON>> searchCartoonDetailsAPI() async{
    var response = await http.get('URL');

    if(response.statusCode == 200){
      List<CartoonDetailsJSON> searchCartoonDetailsURL = parsesCartoon(response.body);
      return searchCartoonDetailsURL;
    } else
      throw Exception('fail in load data');
  }
  static List<CartoonDetailsJSON> parsesCartoon (String responseBody){
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<CartoonDetailsJSON>((json)=> CartoonDetailsJSON.fromJson(json)).toList();
  }

//Text

  static Future<List<TextDetailsJSON>> searchTextDetailsAPI() async{
    var response = await http.get('URL');

    if(response.statusCode == 200){
      List<TextDetailsJSON> searchTextDetailsURL = parsesTexts(response.body);
      return searchTextDetailsURL;
    } else
      throw Exception('fail in load data');
  }
  static List<TextDetailsJSON> parsesTexts (String responseBody){
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<TextDetailsJSON>((json)=> TextDetailsJSON.fromJson(json)).toList();
  }
}