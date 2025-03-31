import '../models/song.dart';

abstract class SongRepository {
  Future<Song> addSong({required String title, required String artist});
  Future<List<Song>> getSongs();
}
