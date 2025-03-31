// REPOSITORY
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'async_value.dart';

// REPOS
abstract class SongRepository {
  Future<Song> addSong({required String title, required String artist});
  Future<List<Song>> getSongs();
}

class FirebaseSongRepository extends SongRepository {
  static const String baseUrl = 'YOUR URL';
  static const String songsCollection = "songs";
  static const String allSongsUrl = '$baseUrl/$songsCollection.json';

  @override
  Future<Song> addSong({required String title, required String artist}) async {
    Uri uri = Uri.parse(allSongsUrl);

    // Create a new data
    final newSongData = {'title': title, 'artist': artist};
    final http.Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newSongData),
    );

    // Handle errors
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to add song');
    }

    // Firebase returns the new ID in 'name'
    final newId = json.decode(response.body)['name'];

    // Return created user
    return Song(id: newId, title: title, artist: artist);
  }

  @override
  Future<List<Song>> getSongs() async {
    Uri uri = Uri.parse(allSongsUrl);
    final http.Response response = await http.get(uri);

    // Handle errors
    if (response.statusCode != HttpStatus.ok &&
        response.statusCode != HttpStatus.created) {
      throw Exception('Failed to load');
    }

    // Return all users
    final data = json.decode(response.body) as Map<String, dynamic>?;

    if (data == null) return [];
    return data.entries
        .map((entry) => SongDto.fromJson(entry.key, entry.value))
        .toList();
  }
}

class MockSongRepository extends SongRepository {
  final List<Song> songs = [];

  @override
  Future<Song> addSong({required String title, required String artist}) {
    return Future.delayed(Duration(seconds: 1), () {
      Song newSong = Song(id: "0", title: title, artist: artist);
      songs.add(newSong);
      return newSong;
    });
  }

  @override
  Future<List<Song>> getSongs() {
    return Future.delayed(Duration(seconds: 1), () => songs);
  }
}

// MODEL & DTO
class SongDto {
  static Song fromJson(String id, Map<String, dynamic> json) {
    return Song(id: id, title: json['title'], artist: json['artist']);
  }

  static Map<String, dynamic> toJson(Song song) {
    return {'title': song.title, 'artist': song.artist};
  }
}

// MODEL
class Song {
  final String id;
  final String title;
  final String artist;

  Song({required this.id, required this.title, required this.artist});

  @override
  bool operator ==(Object other) {
    return other is Song && other.id == id;
  }

  @override
  int get hashCode => super.hashCode ^ id.hashCode;
}

// PROVIDER
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

      // 2 - Fetch users
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
    _repository.addSong(title: title, artist: artist);

    // 2- Call repo to fetch
    fetchSongs();
  }
}

class App extends StatelessWidget {
  const App({super.key});

  void _onAddPressed(BuildContext context) {
    final SongProvider songProvider = context.read<SongProvider>();
    songProvider.addSong("blue", "3.1");
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);

    Widget content = Text('');
    if (songProvider.isLoading) {
      content = CircularProgressIndicator();
    } else if (songProvider.hasData) {
      List<Song> songs = songProvider.songsState!.data!;

      if (songs.isEmpty) {
        content = Text("No data yet");
      } else {
        content = ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(songs[index].title),
            subtitle: Text("${songs[index].artist}"),
            trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => {}),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
              onPressed: () => _onAddPressed(context),
              icon: const Icon(Icons.add))
        ],
      ),
      body: Center(child: content),
    );
  }
}

// 5 - MAIN
void main() async {
  // 1 - Create repository
  final SongRepository songRepository = FirebaseSongRepository();

  // 2-  Run app
  runApp(
    ChangeNotifierProvider(
      create: (context) => SongProvider(songRepository),
      child: MaterialApp(debugShowCheckedModeBanner: false, home: const App()),
    ),
  );
}
