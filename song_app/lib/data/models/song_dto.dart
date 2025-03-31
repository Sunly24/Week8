import 'song.dart';

class SongDto {
  static Song fromJson(String id, Map<String, dynamic> json) {
    return Song(id: id, title: json['title'], artist: json['artist']);
  }

  static Map<String, dynamic> toJson(Song song) {
    return {'title': song.title, 'artist': song.artist};
  }
}
