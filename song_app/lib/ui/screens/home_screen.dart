import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_app/ui/widgets/add_song.dart';

import '../../data/models/song.dart';
import '../provider/song_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);

    Widget content = const Text('');
    if (songProvider.isLoading) {
      content = const CircularProgressIndicator();
    } else if (songProvider.hasData) {
      List<Song> songs = songProvider.songsState!.data!;

      if (songs.isEmpty) {
        content = const Center(
            child: Text("No songs yet",
                style: TextStyle(fontSize: 18, color: Colors.grey)));
      } else {
        content = ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(songs[index].title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(songs[index].artist),
              trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _removeSong(context, songProvider, songs[index])),
            ),
          ),
        );
      }
    } else if (songProvider.songsState?.error != null) {
      content = Center(
        child: Text(
          'Error: ${songProvider.songsState?.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Song App", style: TextStyle(color: Colors.white)),
      ),
      body: content,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddSong(),
        ),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _removeSong(
      BuildContext context, SongProvider songProvider, Song song) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Song'),
          content: Text('Are you sure you want to delete "${song.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                songProvider.removeSong(song.id);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
