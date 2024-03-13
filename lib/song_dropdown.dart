import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'vote_backend.dart';

enum SongAttribute { artist, songName, country }

class CustomPage extends StatefulWidget {
  @override
  CustomPageState createState() => CustomPageState();
}

class CustomPageState extends State<CustomPage> {
  List<String> _songs = [];
  String? _selectedSong;

  @override
  void initState() {
  super.initState();
  fetchSongs(SongAttribute.songName).then((songs) {
    setState(() {
      _songs = songs.map((song) => song['name'] as String).toList();
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
    );
  }
}

Future<List<dynamic>> fetchSongs(SongAttribute attribute) async {
  final response = await http.get(Uri.parse(songsHTTP));
  if (response.statusCode == 200) {
    List<dynamic> songs = jsonDecode(response.body);
    switch (attribute) {
      case SongAttribute.artist:
        return songs.map((song) => {'name': song['artist'], 'id': song['song_id']}).toList();
      case SongAttribute.songName:
        return songs.map((song) => {'name': song['song_name'], 'id': song['song_id']}).toList();
      case SongAttribute.country:
        return songs.map((song) => {'name': song['country'], 'id': song['song_id']}).toList();
      default:
        return [];
    }
  } else {
    throw Exception('Failed to load songs');
  }
}

class SongDropdown extends StatefulWidget {
  final SongAttribute attribute;
  final String? selectedValue;
  final Function(String?, int?) onChanged;

  const SongDropdown({
    Key? key,
    required this.attribute,
    this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _SongDropdownState createState() => _SongDropdownState();
}

class _SongDropdownState extends State<SongDropdown> {
  List<String> _songs = [];
  List<DropdownMenuItem<String>> _dropdownItems = [];
  Map<String, int> _songNameToIdMap = {};

  @override
  void initState() {
    super.initState();
    fetchSongs(widget.attribute).then((songs) {
      setState(() {
          for (var song in songs) {
          String songName = song['name'];
          _songs.add(songName);
          _songNameToIdMap[songName] = song['id'];
        }
        _dropdownItems = _songs.map<DropdownMenuItem<String>>((String name) {
          return DropdownMenuItem<String>(
            value: name,
            child: Flexible(
              child: Text(
                name,
                overflow: TextOverflow.fade,),
            )
          );
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: DropdownButton<String>(
      isExpanded: true,
      value: widget.selectedValue,
      onChanged: (String? newValue) {
        int? newSongId = _songNameToIdMap[newValue];
        widget.onChanged(newValue, newSongId);
      },
      items: _dropdownItems,
      ),
    );
  }
}