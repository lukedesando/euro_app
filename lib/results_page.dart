import 'dart:collection';
import 'dart:convert';
import 'package:euro_app/widgets/theme_switch_button.dart';
import 'package:euro_app/style.dart';
import 'package:flag/flag.dart';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:euro_app/widgets/nav_button.dart';
import 'package:euro_app/main.dart';
import 'package:flutter/material.dart';
import 'vote_backend.dart';
import 'widgets/theme_switch_button.dart';

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
  const ResultsPage({super.key});
  @override
  ResultsPageState createState() => ResultsPageState();
}

class ResultsPageState extends State<ResultsPage> {
  List<dynamic> songs = [];
  bool sortByCountry = true; // Default sort by country
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    fetchSongs();
    _startPolling();
  }
  
  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchSongs();
    });
  }

  fetchSongs() async {
    var url = Uri.parse(songsHTTP);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        songs = json.decode(response.body);
        sortSongs(); // Sort songs based on the selected criteria
      });
      print(response.body);
    } else {
      // Handle server errors
    }
  }

  sortSongs() {
    if (sortByCountry) {
      songs.sort((a, b) => a['country'].compareTo(b['country']));
    } else {
      songs.sort((a, b) => b['average_score'].compareTo(a['average_score']));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Totals from All Voters'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                sortByCountry = !sortByCountry;
                sortSongs();
              });
            },
            child: Text(
              sortByCountry ? 'Sort by Score' : 'Sort by Country',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const logoBlackandWhite(),
        ],
      ),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return ListTile(
            title: Text('${song['country']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${song['song_name']} by ${song['artist']}'),
                Text('Average Score: ${song['average_score']}'),
              ],
            ),
            leading: Flag.fromString(
              song['country_code'] ?? '',
              height: 50,
              width: 75,
            ),
          );
          
        },
      ),
      bottomNavigationBar: BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ThemeSwitcherButton(),
        ],
      ),
    ),
    );
  }
}
