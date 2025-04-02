import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/song.dart';
import '../models/song_dto.dart';
import 'song_repository.dart';

class FirebaseSongRepository extends SongRepository {
  static const String baseUrl =
      'https://mobileapp-3bfbc-default-rtdb.asia-southeast1.firebasedatabase.app';
  static const String songsCollection = "songs";
  static const String allSongsUrl = '$baseUrl/$songsCollection.json';

  @override
  Future<Song> addSong({required String title, required String artist}) async {
    Uri uri = Uri.parse(allSongsUrl);

    // Create a new song data
    final newSongData = {'title': title, 'artist': artist};
    final http.Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newSongData),
    );

    // Handle errors
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to add song. Status: ${response.statusCode}');
    }

    // Firebase returns the new ID in 'name'
    final newId = json.decode(response.body)['name'];

    // Return created song
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

    // Return all songs
    final data = json.decode(response.body) as Map<String, dynamic>?;

    if (data == null) return [];
    return data.entries
        .map((entry) => SongDto.fromJson(entry.key, entry.value))
        .toList();
  }

  @override
  Future<void> removeSong(String id) async {
    Uri uri = Uri.parse('$baseUrl/$songsCollection/$id.json');
    try {
      final http.Response response = await http.delete(uri);

      if (response.statusCode != HttpStatus.ok) {
        throw Exception(
            'Failed to delete song. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete song: $e');
    }
  }
}
