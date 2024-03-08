import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'main.dart';
import 'custom.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eurovision Voting App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String _selectedSong = "";
  List<String> _songs = [];

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  _fetchSongs() async {
    final response = await http.get(Uri.parse('http://localhost:5000/songs'));
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Eurovision Songs'),
        ),
        body: Center(
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
        ),
      ),
    );
  }
}
