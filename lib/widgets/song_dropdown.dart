import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flag/flag.dart';
import '../vote_backend.dart';
import 'favorite_button.dart';

class SongDropdown extends StatefulWidget {
  final Function(int, String) onSongSelected;
  final int songId;
  final String userName;

  const SongDropdown({
    Key? key,
    required this.onSongSelected,
    required this.songId,
    required this.userName,
  }) : super(key: key);

  @override
  _SongDropdownState createState() => _SongDropdownState();
}


class _SongDropdownState extends State<SongDropdown> {
  List<dynamic> songs = [];
  String? _selectedSong;

  Map<String, String> displayInfo = {
    'country': '',
    'song_name': '',
    'artist': '',
  };
  String displaySelection = 'country'; // Options: 'country', 'song_name', 'artist'

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  fetchSongs() async {
    var url = Uri.parse(songsHTTP);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        songs = json.decode(response.body);
        songs.sort((a, b) => a['country'].compareTo(b['country']));  // Sort the list by the 'name' property
      });
    } else {
      // Handle server errors
    }
  }

  @override
  Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          displaySelection == 'country' && displayInfo['country'] != '' && displayInfo['country_code'] != 'Unknown'
              ? Flag.fromString(
                  displayInfo['country_code'] ?? '',
                  height: 50,
                  width: 65,
                )
              : Container(),
          SizedBox(width: 10),
          Text('Song is: ${displayInfo['song_name'] ?? ''}'),
        ],
      ),
      SizedBox(height: 10),
      Row(
        children: [
          DropdownButton<String>(
            value: _selectedSong,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? newValue) {
              setState(() {
                _selectedSong = newValue!;
                var selectedSong = songs.firstWhere(
                  (song) => song[displaySelection] == newValue,
                  orElse: () => {},
                );
                displayInfo['country'] = selectedSong['country'] ?? '';
                displayInfo['song_name'] = selectedSong['song_name'] ?? '';
                displayInfo['artist'] = selectedSong['artist'] ?? '';
                displayInfo['country_code'] = selectedSong['country_code'] ?? '';
                widget.onSongSelected(selectedSong['song_id'], selectedSong['song_name']); // Call the callback function with the song ID
              });
            },
            items: songs.map<DropdownMenuItem<String>>((dynamic song) {
              return DropdownMenuItem<String>(
                value: song[displaySelection],
                child: Text(song[displaySelection]),
              );
            }).toList(),
          ),
          FavoriteButton(
            songId: widget.songId,
            userName: widget.userName,
          ),
        ],
      ),
    ],
  );
}
}
