import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/song_dropdown.dart';
import 'widgets/score_slider.dart';
import 'widgets/vote_button.dart';
import 'widgets/name_input.dart';
import 'widgets/nav_button.dart';
import 'widgets/theme_switch_button.dart';
import 'widgets/favorite_button.dart';

import 'style.dart';
import 'package:euro_app/results_page.dart';

void main() {
  runApp(ChangeNotifierProvider<ThemeProvider>(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  // runApp(MyApp()
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Eurovision Voting App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
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
    appBar: const appbar_euro(title: 'Vote for Eurovision Song'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Song:'),
            SongDropdown(
              onSongSelected: (int id, String name){
                setState(() {
                  _selectedSongID = id;
                  selectedSong = name;
                });
              },
            ),
            FavoriteButton(songId: _selectedSongID ?? 1,
            userName: currentUserName ?? ''),            
            const SizedBox(height: 20),
            ScoreSlider(onScoreChanged: _onScoreChanged),
            const SizedBox(height: 20),
            NameInputField(
              controller: nameController,
              onNameChanged: _onNameChanged,
            ),
            SizedBox(height: 20),
            Center(
              child:
            VoteButton(songName: selectedSong ?? 'No Song Selected',
                      songId: _selectedSongID ?? 0,
                      userName: nameController.text,
                      score: _currentScore),
            ),
          ],
        ),
      ),
    bottomNavigationBar: BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NavigationButton(
            buttonText: 'Show My Results',
            nextPage: ResultsPage(userName: currentUserName,),
          ),
          ThemeSwitcherButton(),
        ],
      ),
    ),
    );
  }
}