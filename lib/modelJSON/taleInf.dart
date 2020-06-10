//music.dart audioTales.dart cartoons.dart
class TaleInf {
  final String id;
  final String name, desc, count, smokingContent, iosContent;

  TaleInf({
    this.id,
    this.name,
    this.desc,
    this.count,
    this.smokingContent,
    this.iosContent,
  });

  factory TaleInf.fromJson(Map<String, dynamic> jsonData){
    return TaleInf(
      id: jsonData['id'],
      name: jsonData['name'],
      desc: jsonData['desc'],
      count: jsonData['count'],
      smokingContent: jsonData['smoking_content'],
      iosContent: jsonData['ios_disable'],
    );
  }
}

//audioTaleDetails.dart
class AudioTaleDetailsJSON {
  final String pageId, id, stId;
  final String name, size, rating, author,duration, img, iosImage;
   bool favorite;

  AudioTaleDetailsJSON({
    this.id,
    this.stId,
    this.pageId,
    this.rating,
    this.size,
    this.author,
    this.duration,
    this.name,
    this.img,
    this.favorite,
    this.iosImage,
  });

  factory AudioTaleDetailsJSON.fromJson(Map<String, dynamic> jsonData) => AudioTaleDetailsJSON(
      id: jsonData['id'],
      stId: jsonData['set_id'],
      pageId: jsonData['page_id'],
      rating: jsonData['rating'],
      size: jsonData['mp3_size'],
      duration: jsonData['duration'],
      name: jsonData['name'],
      author: jsonData['author'],
      img: jsonData['has_img'],
      iosImage: jsonData['ios_image'],
      favorite: false,
    );

  Map<String, dynamic> toJson() =>{
    'id': id,
    'set_id': stId,
    'pageId': pageId,
    'rating': rating,
    'mp3_size': size,
    'duration': duration,
    'name': name,
    'author': author,
    'has_img': img,
    'ios_image': iosImage,
    'favorite': favorite,
  };
}

//musicDetails.dart
class MusicDetailsJSON {
  final String pageId, id, stId;
  final String name, size, rating, duration, img;
  bool favorite;

  MusicDetailsJSON({
    this.id,
    this.stId,
    this.pageId,
    this.rating,
    this.size,
    this.duration,
    this.name,
    this.img,
    this.favorite,
  });

  factory MusicDetailsJSON.fromJson(Map<String, dynamic> jsonData) => MusicDetailsJSON(
      id: jsonData['id'],
      stId: jsonData['set_id'],
      pageId: jsonData['page_id'],
      rating: jsonData['rating'],
      size: jsonData['mp3_size'],
      duration: jsonData['duration'],
      name: jsonData['name'],
      img: jsonData['has_img'],
      favorite: false,
    );

  Map<String, dynamic> toJson() =>{
    'id': id,
    'set_id': stId,
    'pageId': pageId,
    'rating': rating,
    'mp3_size': size,
    'duration': duration,
    'name': name,
    'has_img': img,
    'favorite': favorite,
  };
}
//cartoonDetails
class CartoonDetailsJSON {
  final String pageId, id, stId;
  final String name, author, popularity, duration, img, url;

  CartoonDetailsJSON({
    this.id,
    this.stId,
    this.pageId,
    this.author,
    this.popularity,
    this.duration,
    this.name,
    this.img,
    this.url,
  });

  factory CartoonDetailsJSON.fromJson(Map<String, dynamic> jsonData) => CartoonDetailsJSON(
      id: jsonData['id'],
      stId: jsonData['set_id'],
      pageId: jsonData['page_id'],
      author: jsonData['author'],
      popularity: jsonData['popularity'],
      duration: jsonData['duration'],
      name: jsonData['name'],
      img: jsonData['has_img'],
      url: jsonData['caf_size'],
    );
  Map<String, dynamic> toJson() =>{
    'id': id,
    'set_id': stId,
    'pageId': pageId,
    'author': author,
    'popularity': popularity,
    'duration': duration,
    'name': name,
    'has_img': img,
    'caf_size': url,
  };
}

class FilmDetailsJSON {
  final String pageId, id, stId;
  final String name, author, popularity, duration, img, url;

  FilmDetailsJSON({
    this.id,
    this.stId,
    this.pageId,
    this.author,
    this.popularity,
    this.duration,
    this.name,
    this.img,
    this.url,
  });

  factory FilmDetailsJSON.fromJson(Map<String, dynamic> jsonData) => FilmDetailsJSON(
      id: jsonData['id'],
      stId: jsonData['set_id'],
      pageId: jsonData['page_id'],
      author: jsonData['author'],
      popularity: jsonData['popularity'],
      duration: jsonData['duration'],
      name: jsonData['name'],
      img: jsonData['has_img'],
      url: jsonData['caf_size'],
    );

  Map<String, dynamic> toJson() =>{
    'id': id,
    'set_id': stId,
    'pageId': pageId,
    'author': author,
    'popularity': popularity,
    'duration': duration,
    'name': name,
    'has_img': img,
    'caf_size': url,
  };
}

class TextDetailsJSON {
  final String pageId, id, stId;
  final String name, author, popularity, duration, img;
  bool favorite;

  TextDetailsJSON({
    this.id,
    this.stId,
    this.pageId,
    this.author,
    this.popularity,
    this.duration,
    this.name,
    this.img,
    this.favorite,
  });

  factory TextDetailsJSON.fromJson(Map<String, dynamic> jsonData)=> TextDetailsJSON(
      id: jsonData['id'],
      stId: jsonData['set_id'],
      pageId: jsonData['page_id'],
      author: jsonData['author'],
      popularity: jsonData['popularity'],
      duration: jsonData['duration'],
      name: jsonData['name'],
      img: jsonData['has_img'],
      favorite: false,
    );

  Map<String, dynamic> toJson() =>{
    'id': id,
    'set_id': stId,
    'pageId': pageId,
    'author': author,
    'popularity': popularity,
    'duration': duration,
    'name': name,
    'has_img': img,
    'favorite': favorite,
  };

}

class FilmstripDetailsJSON {
  final String pageId, id, stId;
  final String name, author, popularity, duration, img, size;
  bool favorite;

  FilmstripDetailsJSON({
    this.id,
    this.stId,
    this.pageId,
    this.author,
    this.popularity,
    this.duration,
    this.name,
    this.img,
    this.size,
    this.favorite,
  });

  factory FilmstripDetailsJSON.fromJson(Map<String, dynamic> jsonData) => FilmstripDetailsJSON(
    id: jsonData['id'],
    stId: jsonData['set_id'],
    pageId: jsonData['page_id'],
    author: jsonData['author'],
    popularity: jsonData['popularity'],
    duration: jsonData['duration'],
    name: jsonData['name'],
    img: jsonData['has_img'],
    size: jsonData['caf_size'],
  );
  Map<String, dynamic> toJson() =>{
    'id': id,
    'set_id': stId,
    'pageId': pageId,
    'author': author,
    'popularity': popularity,
    'duration': duration,
    'name': name,
    'has_img': img,
    'caf_size': size,
  };
}

class SearchJSON {
  final int type;
  final String pageId, id, stId;
  final String name, author, rating, duration, size;
  bool favorite;

  SearchJSON({
    this.type,
    this.id,
    this.stId,
    this.pageId,
    this.author,
    this.rating,
    this.duration,
    this.name,
    this.size,
    this.favorite,
  });
}