import 'dart:async';
import 'dart:convert';
import 'package:euro_app/widgets/grids/our_results_grid.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:euro_app/widgets/buttons/theme_switch_button.dart';
import 'package:euro_app/styles/style.dart';
import '../http_util.dart';
import 'package:pluto_grid/pluto_grid.dart';

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
  late PlutoGridStateManager stateManager;
  
  @override
  void initState() {
    super.initState();
    fetchSongs();
    fetchVotes().then((votes) {
      setState(() {
        userVotes = votes;
      });
    });
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

  void fetchSongs() async {
    var url = Uri.parse(songsHTTP);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        songs = json.decode(response.body);
        // Assume userVotes are fetched similarly or passed some other way
      });
    }
  }

  Future<Map<int, int>> fetchVotes() async {
    if (widget.userName == null) return {};
    var url = Uri.parse('$voteGetHTTP?user_name=${widget.userName}');
    var response = await http.get(url);
    Map<int, int> votes = {};
    if (response.statusCode == 200) {
      List<dynamic> voteData = json.decode(response.body);
      for (var vote in voteData) {
        votes[vote['song_id']] = vote['user_score'];
      }
    }
    return votes;
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
        title: const Text('Results'),
        centerTitle: false,
        actions: [
          const LogoBlackandWhite(),
        ],
      ),
      
      body: songs.isEmpty
      ? CircularProgressIndicator()
      : SongGrid(songs:songs, userVotes: userVotes),
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
