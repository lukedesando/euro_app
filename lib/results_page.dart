import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flag/flag.dart';
import 'package:euro_app/widgets/nav_button.dart';
import 'package:euro_app/widgets/theme_switch_button.dart';
import 'package:euro_app/style.dart';
import 'vote_backend.dart';

class ResultsPage extends StatefulWidget {
  final String? userName;
  ResultsPage({super.key, this.userName});

  @override
  ResultsPageState createState() => ResultsPageState();
}

class ResultsPageState extends State<ResultsPage> {
  List<dynamic> songs = [];
  bool sortByCountry = true; // Default sort by country
  Timer? _pollingTimer;
  Map<int, int> userVotes = {};
  bool showUnvotedOnly = false;

  @override
  void initState() {
    super.initState();
    fetchSongs();
    if (widget.userName != null) {
    fetchVotes(widget.userName).then((votes) {
      setState(() {
        userVotes = votes;
      });
    });
  }
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
      // print(response.body);
    } else {
      // Handle server errors
    }
  }

  Future<Map<int, int>> fetchVotes(String? userName) async {
  var url = Uri.parse('$voteGetHTTP?user_name=$userName');
  var response = await http.get(url);
  Map<int, int> userVotes = {};
  if (response.statusCode == 200) {
    List<dynamic> votes = json.decode(response.body);
    for (var vote in votes) {
      userVotes[vote['song_id']] = vote['user_score'];
    }
  }
  return userVotes;
}

  sortSongs() {
  if (sortByCountry) {
    songs.sort((a, b) => a['country'].compareTo(b['country']));
  } else {
    songs.sort((a, b) {
      int scoreComparison = b['average_score'].compareTo(a['average_score']);
      if (scoreComparison != 0) {
        return scoreComparison;
      } else {
        return a['country'].compareTo(b['country']);
      }
    });
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
                showUnvotedOnly = !showUnvotedOnly;
              });
            },
            child: Text(
              showUnvotedOnly ? 'Show All' : "Hide Songs I Voted On",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          TextButton(
            onPressed: () {
              setState(() {
                sortByCountry = !sortByCountry;
                sortSongs();
              });
            },
            child: Text(
              sortByCountry ? 'Sort by Score' : 'Sort Alphabetically',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const LogoBlackandWhite(),
        ],
      ),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
              if (showUnvotedOnly && userVotes.containsKey(song['song_id'])) {
              return SizedBox.shrink(); // Don't show voted songs
              }
          return ListTile(
            title: Text('${song['country']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${song['song_name']} by ${song['artist']}'),
                Text('My Score: ${userVotes[song['song_id']] ?? "Not Voted"}'), // Display the user's score
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
