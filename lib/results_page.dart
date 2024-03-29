import 'dart:collection';

import 'package:euro_app/assets/components/nav_button.dart';
import 'package:euro_app/main.dart';
import 'package:flutter/material.dart';

// A simple data model for a song entry
class SongEntry {
  final String country;
  final String songName;
  final String artist;
  final double averageScore;

  SongEntry({
    required this.country,
    required this.songName,
    required this.artist,
    required this.averageScore,
  });
}

void main() {
  runApp(MaterialApp(home: ResultsPage()));
}

class ResultsPage extends StatefulWidget {
  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  // Dummy data for demonstration purposes
  // Replace this with your actual data fetching logic
  List<SongEntry> songs = [
    SongEntry(country: 'Country 1', songName: 'Song 1', artist: 'Artist 1', averageScore: 8.5),
    SongEntry(country: 'Country 2', songName: 'Song 2', artist: 'Artist 2', averageScore: 7.2),
    SongEntry(country: 'Country 3', songName: 'Song 3', artist: 'Artist 3', averageScore: 9.1),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
      ),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return ListTile(
            title: Text('${song.songName} by ${song.artist}'),
            subtitle: Text('Country: ${song.country} - Average Score: ${song.averageScore.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}
