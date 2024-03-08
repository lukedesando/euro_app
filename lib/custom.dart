import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String songsHTTP = 'http://localhost:5000/songs';
const String voteHTTP = 'http://localhost:5000/songs';

class CustomPage extends StatefulWidget {
  @override
  CustomPageState createState() => CustomPageState();
}

class CustomPageState extends State<CustomPage> {
  String _selectedSong = "";
  List<String> _songs = [];
  double score = 5.0;
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  _fetchSongs() async {
    final response = await http.get(Uri.parse(songsHTTP));
    if (response.statusCode == 200) {
      setState(() {
        _songs = List<String>.from(json.decode(response.body));
        if (_songs.isNotEmpty) {
          _selectedSong = _songs[0];
        }
      });
    } else {
      throw Exception('Failed to load songs');
    }
  }

  void saveVote(String songName) async {
    final response = await http.post(Uri.parse(voteHTTP),
      body: {
        'song_name': _selectedSong,
        'score': score.toString(),
        'user_name': nameController.text,
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vote saved successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving vote')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Eurovision Songs'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SongDropdown(apiUrl: songsHTTP),
              VotingSlider(
                score: score,
                onChanged: (newScore) {
                  setState(() {
                    score = newScore;
                  });
                },
              ),
              SaveVoteButton(
                saveVote: saveVote,
                selectedSong: _selectedSong,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VoteWidget extends StatelessWidget {
  final Widget child;

  const VoteWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class VotingSlider extends StatelessWidget {
  final double score;
  final Function(double) onChanged;

  const VotingSlider({
    Key? key,
    required this.score,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VoteWidget(
      child: Column(
        children: <Widget>[
          Text('Score:'),
          Slider(
            value: score,
            onChanged: onChanged,
            min: 0,
            max: 10,
            divisions: 10,
            label: score.toStringAsFixed(1),
          ),
        ],
      ),
    );
  }
}

class SaveVoteButton extends StatelessWidget {
  final Function(String) saveVote;
  final String selectedSong;

  const SaveVoteButton({
    Key? key,
    required this.saveVote,
    required this.selectedSong,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VoteWidget(
      child: ElevatedButton(
        onPressed: () => saveVote(selectedSong),
        child: Text('Save Vote'),
      ),
    );
  }
}

class SongDropdown extends StatefulWidget {
  final String apiUrl;

  const SongDropdown({Key? key, required this.apiUrl}) : super(key: key);

  @override
  _SongDropdownState createState() => _SongDropdownState();
}

class _SongDropdownState extends State<SongDropdown> {
  String _selectedSong = "";
  List<String> _songs = [];

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  _fetchSongs() async {
    final response = await http.get(Uri.parse(widget.apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        _songs = List<String>.from(json.decode(response.body));
        if (_songs.isNotEmpty) {
          _selectedSong = _songs[0];
        }
      });
    } else {
      throw Exception('Failed to load songs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return VoteWidget(
      child: _songs.isNotEmpty
          ? DropdownButton<String>(
              value: _selectedSong,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSong = newValue!;
                });
              },
              items: _songs.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            )
          : CircularProgressIndicator(),
    );
  }
}
