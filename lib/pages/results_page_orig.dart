import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flag/flag.dart';
import 'package:euro_app/widgets/buttons/theme_switch_button.dart';
import 'package:euro_app/styles/style.dart';
import '../http_util.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../widgets/grids/initial_grid.dart';

class ResultsPageOrig extends StatefulWidget {
  final String? userName;
  ResultsPageOrig({super.key, this.userName});

  @override
  ResultsPageState createState() => ResultsPageState();
}

class ResultsPageState extends State<ResultsPageOrig> {
  List<dynamic> songs = [];
  bool sortByCountry = true; // Default sort by country
  Timer? _pollingTimer;
  Map<int, int> userVotes = {};
  bool showUnvotedOnly = false;
  double flagheight = 50;
  late PlutoGridStateManager stateManager;


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
  
  List<PlutoRow> generateRows(List<dynamic> songs) {
    return songs.map((song) => PlutoRow(
      cells: {
        'country': PlutoCell(value: song['country']),
        'song_name': PlutoCell(value: song['song_name']),
        'artist': PlutoCell(value: song['artist']),
        'average_score': PlutoCell(value: song['average_score'].toString()),
      }
    )).toList();
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
          OutlinedButton(
            onPressed: () {
              setState(() {
                showUnvotedOnly = !showUnvotedOnly;
              });
            },
            child: Text(
              showUnvotedOnly ? 'Show All' : "Hide Voted Songs",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          OutlinedButton(
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
      body: InitialGrid(
        songs: songs,
        userVotes: userVotes,
        showUnvotedOnly: showUnvotedOnly,
      ),
      // body: ListView.builder(
      //   itemCount: songs.length,
      //   itemBuilder: (context, index) {
      //     final song = songs[index];
      //         if (showUnvotedOnly && userVotes.containsKey(song['song_id'])) {
      //         return SizedBox.shrink(); // Don't show voted songs
      //         }
      //     return ListTile(
      //       title: Text('${song['country']}'),
      //       subtitle: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Text('${song['song_name']}'),
      //           Text('by ${song['artist']}'),
      //           Text('My Score: ${userVotes[song['song_id']] ?? "Not Voted"}'), // Display the user's score
      //           Text('Average Score: ${song['average_score']}'),
      //         ],
      //       ),
      //       leading: Flag.fromString(
      //         song['country_code'] ?? '',
      //         height: flagheight,
      //         width: flagheight*1.5,
      //       ),
      //     );
      //   },
      // ),
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
