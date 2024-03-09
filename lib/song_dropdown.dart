import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'vote_widget.dart';


enum SongAttribute { artist, songName, country }

const String songsHTTP = 'http://localhost:5000/songs';
const String voteHTTP = 'http://localhost:5000/vote';

class CustomPage extends StatefulWidget {
  @override
  CustomPageState createState() => CustomPageState();
}

class CustomPageState extends State<CustomPage> {
  List<String> _songs = [];
  String? _selectedSong;
  double score = 5.0;


  @override
  void initState() {
    super.initState();
    fetchSongs(SongAttribute.songName).then((songs) {
      setState(() {
        _songs = songs;
        if (_songs.isNotEmpty) {
          _selectedSong = _songs[0];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Page'),
      ),
      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       if (_songs.isNotEmpty)
      //         DropdownButton<String>(
      //           value: _selectedSong,
      //           onChanged: (String? newValue) {
      //             setState(() {
      //               _selectedSong = newValue;
      //             });
      //           },
      //           items: _songs.map<DropdownMenuItem<String>>((String value) {
      //             return DropdownMenuItem<String>(
      //               value: value,
      //               child: Text(value),
      //             );
      //           }).toList(),
      //         ),
      //       // ElevatedButton(
      //       //   onPressed: () {
      //       //     Navigator.push(
      //       //       context,
      //       //       // MaterialPageRoute(builder: (context) => VotePage(songName: _selectedSong ?? 'No Song Selected')),
      //       //     );
      //       //   },
      //       //   child: Text('Go to Vote Page'),
      //       // ),
      //     ],
      //   ),
      // ),
    );
  }
}

Future<List<String>> fetchSongs(SongAttribute attribute) async {
  final response = await http.get(Uri.parse('http://localhost:5000/songs'));
  if (response.statusCode == 200) {
    List<dynamic> songs = jsonDecode(response.body);
    switch (attribute) {
      case SongAttribute.artist:
        return songs.map((song) => song['artist'] as String).toList();
      case SongAttribute.songName:
        return songs.map((song) => song['song_name'] as String).toList();
      case SongAttribute.country:
        return songs.map((song) => song['country'] as String).toList();
      default:
        return [];
    }
  } else {
    throw Exception('Failed to load songs');
  }
}

class SongDropdown extends StatefulWidget {
  final SongAttribute attribute;

  const SongDropdown({Key? key, required this.attribute}) : super(key: key);

  @override
  _SongDropdownState createState() => _SongDropdownState();
}

class _SongDropdownState extends State<SongDropdown> {
  List<String> _songs = [];
  String? _selectedSong;

  @override
  void initState() {
    super.initState();
    fetchSongs(widget.attribute).then((songs) {
      setState(() {
        _songs = songs;
        if (_songs.isNotEmpty) {
          _selectedSong = _songs[0];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedSong,
      onChanged: (String? newValue) {
        setState(() {
          _selectedSong = newValue;
        });
      },
      items: _songs.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     home: Scaffold(
  //       appBar: AppBar(
  //         title: Text('Eurovision Songs'),
  //       ),
  //       body: Center(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             SongDropdown(attribute: SongAttribute.songName),
  //             VotingSlider(
  //               score: score,
  //               onChanged: (newScore) {
  //                 setState(() {
  //                   score = newScore;
  //                 });
  //               },
  //             ),
  //             SaveVoteButton(
  //               saveVote: saveVote,
  //               selectedSong: _selectedSong,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return VoteWidget(
  //     child: _songs.isNotEmpty
  //         ? DropdownButton<String>(
  //             value: _selectedSong,
  //             onChanged: (String? newValue) {
  //               setState(() {
  //                 _selectedSong = newValue!;
  //               });
  //             },
  //             items: _songs.map<DropdownMenuItem<String>>((String value) {
  //               return DropdownMenuItem<String>(
  //                 value: value,
  //                 child: Text(value),
  //               );
  //             }).toList(),
  //           )
  //         : CircularProgressIndicator(),
  //   );
  // }