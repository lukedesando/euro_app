import 'package:euro_app/assets/components/input_fields.dart';
import 'package:euro_app/assets/components/persistent_tabs.dart';
import 'package:euro_app/assets/components/score_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:http/http.dart' as http;

import 'second_option_page.dart';
import 'test_page.dart';
import 'assets/components/song_dropdown.dart';
import 'assets/components/score_slider.dart';
import 'assets/components/vote_button.dart';
import 'assets/components/name_input.dart';

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
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedSong;
  double _currentScore = 5.0; //Default score
  int? _selectedSongID;
  String? currentUserName;
  final TextEditingController nameController = TextEditingController();

  void _onSongChanged(String? newSongName, int? newSongId) {
    setState(() {
      selectedSong = newSongName;
      _selectedSongID = newSongId;
    });
  }

  void _onScoreChanged(double newScore) {
    setState(() {
      _currentScore = newScore;
    });
  }

    void _onNameChanged(String newUserName) {
    setState(() {
      currentUserName = newUserName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
        children: [
        Image.asset('assets/images/logo.png', height: 40),
          SizedBox(width: 10), // Add some space between the logo and the text
          Text('Vote for Eurovision Song'),
        ],
      ),
    ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Song:'),
            SongDropdown(
              onSongSelected: (int id, String name){
                setState(() {
                  _selectedSongID = id;
                  selectedSong = name;
                });
              },
            ),            
            SizedBox(height: 20),
            // Text('Or Select Country:'),
            // SongDropdown( attribute: SongAttribute.country,
            //   selectedValue: _selectedSong,
            //   onChanged: _onSongChanged),            
            // SizedBox(height: 20), #FIXME I want to get both and update both!
            ScoreSlider(onScoreChanged: _onScoreChanged),
            // VotingDropdown(onScoreSelected: _onScoreChanged),
            SizedBox(height: 20),
            NameInputField(
              controller: nameController,
              onNameChanged: _onNameChanged,
            ),
            SizedBox(height: 20),
            Center(
              child:
            VoteButton(songName: selectedSong ?? 'No Song Selected', songId: _selectedSongID ?? 0, userName: nameController.text, score: _currentScore),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VotePage()),
                  );  
                },
                // style: ElevatedButton.styleFrom(primary: Colors.blue),
                child: Text('Show Me Another Style'),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SimpleTextFields()),
                  );  
                },
                // style: ElevatedButton.styleFrom(primary: Colors.blue),
                child: Text('Show TextFields'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}