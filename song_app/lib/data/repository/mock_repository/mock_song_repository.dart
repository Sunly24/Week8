import '../../models/song.dart';
import '../song_repository.dart';

class MockSongRepository extends SongRepository {
  final List<Song> songs = [];

  @override
  Future<Song> addSong({required String title, required String artist}) {
    return Future.delayed(const Duration(seconds: 1), () {
      Song newSong = Song(id: "0", title: title, artist: artist);
      songs.add(newSong);
      return newSong;
    });
  }

  @override
  Future<List<Song>> getSongs() {
    return Future.delayed(const Duration(seconds: 1), () => songs);
  }

  @override
  Future<void> removeSong(String id) {
    return Future.delayed(const Duration(seconds: 1), () {
      songs.removeWhere((song) => song.id == id);
    });
  }
}
