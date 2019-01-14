/// 图片域名
const image_domain = "http://nextday-pic.b0.upaiyun.com";

/// 音乐域名
const music_domain = "http://nextday-file.b0.upaiyun.com";

/// 视频域名
const video_domain = "http://nextday-file.b0.upaiyun.com";

class InfoModel {
  static final empty = new InfoModel();
  String dateKey;
  AuthorModel author;
  TextModel text;
  GeoModel geo;
  String event;
  ColorsModel colors;
  MusicModel music;
  Map<String, dynamic> images;
  DateTime _dateTime;

  InfoModel();

  InfoModel.fromJson(Map<String, dynamic> json)
      : dateKey = json['dateKey'],
        author = json['author'] != null
            ? AuthorModel.fromJson(json['author'])
            : null,
        text = TextModel.fromJson(json['text']),
        geo = GeoModel.fromJson(json['geo']),
        event = json['event'],
        colors = ColorsModel.fromJson(json['colors']),
        music = MusicModel.fromJson(json['music']),
        images = json['images'];

  static String realMusicPath(String placeholderPath) {
    return placeholderPath.replaceAll(new RegExp(r'\{music\}'),music_domain);
  }

  static String realImagePath(String placeholderPath) {
    return placeholderPath.replaceAll(new RegExp(r'\{img\}'), image_domain);
  }

  DateTime getDateTime() {
    return _dateTime ??= new DateTime(_getYear(), _getMonth(), _getDay());
  }

  int _getYear() {
    return int.parse(dateKey.substring(0, 4));
  }

  int _getMonth() {
    return int.parse(dateKey.substring(4, 6));
  }

  int _getDay() {
    return int.parse(dateKey.substring(6));
  }
}

class AuthorModel {
  String name;

  AuthorModel.fromJson(Map<String, dynamic> json) : name = json['name'];
}

class TextModel {
  String comment1;
  String comment2;
  String short;

  TextModel.fromJson(Map<String, dynamic> json)
      : comment1 = json['comment1'],
        comment2 = json['comment2'],
        short = json['short'];
}

class GeoModel {
  String reverse;

  GeoModel.fromJson(Map<String, dynamic> json) : reverse = json['reverse'];
}

class ColorsModel {
  String background;

  ColorsModel.fromJson(Map<String, dynamic> json)
      : background = json['background'];
}

class MusicModel {
  String title;
  String artist;
  String name;
  String url;

  MusicModel.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        artist = json['artist'],
        name = json['name'],
        url = json['url'];
}
