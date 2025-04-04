import 'package:flutter/material.dart';

import '../../data/models/song.dart';
import '../../data/repository/song_repository.dart';
import 'async_value.dart';

class SongProvider extends ChangeNotifier {
  final SongRepository _repository;
  AsyncValue<List<Song>>? songsState;

  SongProvider(this._repository) {
    fetchSongs();
  }

  bool get isLoading =>
      songsState != null && songsState!.state == AsyncValueState.loading;
  bool get hasData =>
      songsState != null && songsState!.state == AsyncValueState.success;

  void fetchSongs() async {
    try {
      // 1- loading state
      songsState = AsyncValue.loading();
      notifyListeners();

      // 2 - Fetch songs
      songsState = AsyncValue.success(await _repository.getSongs());

      print("SUCCESS: list size ${songsState!.data!.length.toString()}");

      // 3 - Handle errors
    } catch (error) {
      print("ERROR: $error");
      songsState = AsyncValue.error(error);
    }

    notifyListeners();
  }

  void addSong(String title, String artist) async {
    // 1- Call repo to add
    Song newSong = await _repository.addSong(title: title, artist: artist);

    // 2- Update
    if (hasData) {
      List<Song> updatedSongs = List<Song>.from(songsState!.data!);
      updatedSongs.add(newSong);
      songsState = AsyncValue.success(updatedSongs);
      notifyListeners();
    }
  }

  void removeSong(String id) async {
    // 2- Fetch songs
    if (hasData) {
      List<Song> songs = List<Song>.from(songsState!.data!);
      List<Song> updatedSongs = songs.where((song) => song.id != id).toList();
      songsState = AsyncValue.success(updatedSongs);
      notifyListeners();
    }

    // 1- Call repo to remove
    await _repository.removeSong(id);
  }
}
