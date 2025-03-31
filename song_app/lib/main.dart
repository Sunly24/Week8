import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_app/data/repository/firebase_song_repository.dart';
import 'package:song_app/data/repository/song_repository.dart';

import 'ui/provider/song_provider.dart';
import 'ui/screens/home_screen.dart';

// 5 - MAIN
void main() async {
  // 1 - Create repository
  final SongRepository songRepository = FirebaseSongRepository();

  // 2-  Run app
  runApp(
    ChangeNotifierProvider(
      create: (context) => SongProvider(songRepository),
      child: MaterialApp(
          debugShowCheckedModeBanner: false, home: const HomeScreen()),
    ),
  );
}
