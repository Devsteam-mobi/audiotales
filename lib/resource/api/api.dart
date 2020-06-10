import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audiotales/modelJSON/taleInf.dart';

Future<List<TaleInf>> audioTaleAPI() async{
  var response = await http.get('URL');

  if(response.statusCode == 200){
    List audioTalesURL = json.decode(response.body);
    var audioTaleRes = audioTalesURL
        .map((taleInf) => new TaleInf.fromJson(taleInf))
        .toList();
    if (Platform.isIOS) {
      for (int i = 0; i < audioTaleRes.length; i++) {
        if (audioTaleRes[i].iosContent == '1') {
          audioTaleRes.remove(audioTaleRes[i]);
        }
      }
    }
    return audioTaleRes;
  } else
    throw Exception('fail in load data');
}

Future<List<TaleInf>> musicAPI() async {
  var response = await http.get('URL');

  if (response.statusCode == 200) {
    List musicURL = json.decode(response.body);
    var resultMusic = musicURL
        .map((taleInf) => new TaleInf.fromJson(taleInf))
        .toList();
    if (Platform.isIOS) {
      for (int i = 0; i < resultMusic.length; i++) {
        if (resultMusic[i].iosContent == '1') {
          resultMusic.remove(resultMusic[i]);
        }
      }
    }
        return resultMusic;
      } else
      throw Exception('fail in load data');
  }

Future<List<TaleInf>> cartoonsAPI() async{
  var response = await http.get('URL');

  if(response.statusCode == 200){
    List cartoonURL = json.decode(response.body);
    var resultCartoon = cartoonURL
        .map((taleInf) => new TaleInf.fromJson(taleInf))
        .toList();
      for (int i = 0; i < resultCartoon.length; i++) {
        if (resultCartoon[i].smokingContent == '1') {
          resultCartoon.remove(resultCartoon[i]);
        }
    }
    return resultCartoon;
  } else
    throw Exception('fail in load data');
}

Future<List<TaleInf>> filmsAPI() async{
  var response = await http.get('URL');

  if(response.statusCode == 200){
    List filmsURL = json.decode(response.body);
    return filmsURL
        .map((taleInf) => new TaleInf.fromJson(taleInf))
        .toList();
  } else
    throw Exception('fail in load data');
}

Future<List<TaleInf>> textsAPI() async{
  var response = await http.get('URL');

  if(response.statusCode == 200){
    List textsURL = json.decode(response.body);
    var resultText =  textsURL
        .map((taleInf) => new TaleInf.fromJson(taleInf))
        .toList();
      for (int i = 0; i < resultText.length; i++) {
          if (resultText[i].smokingContent == '1') {
            resultText.remove(resultText[i]);
          }
      }
    return resultText;
  } else
    throw Exception('fail in load data');
}

Future<List<TaleInf>> filmstripsAPI() async{
  var response = await http.get('URL');


  if(response.statusCode == 200){
    List filmstripsURL = json.decode(response.body);
    return filmstripsURL
        .map((taleInf) => new TaleInf.fromJson(taleInf))
        .toList();
  } else
    throw Exception('fail in load data');
}