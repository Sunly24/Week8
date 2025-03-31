import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/song.dart';
import '../provider/song_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
