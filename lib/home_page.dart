import 'package:flutter/material.dart';

import 'widgets/song_dropdown.dart';
import 'widgets/score_slider.dart';
import 'widgets/vote_button.dart';
import 'widgets/name_input.dart';
import 'widgets/nav_button.dart';
import 'widgets/theme_switch_button.dart';
import 'widgets/glitter_box.dart';

import 'style.dart';
import 'package:euro_app/results_page.dart';
import 'package:euro_app/favorites_page.dart';

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
      body: GlitterBox(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NameInputField(
                controller: nameController,
                onNameChanged: _onNameChanged,
              ),
              SizedBox(height: 20),
              const Text('Select Country:'),
              SongDropdown(
                onSongSelected: (int id, String name) {
                  setState(() {
                    _selectedSongID = id;
                    selectedSong = name;
                  });
                },
                songId: _selectedSongID ?? 0,
                userName: currentUserName ?? '',
              ),
              SizedBox(height: 20),
              ScoreSlider(onScoreChanged: _onScoreChanged),
              SizedBox(height: 20),
              Center(
                child: VoteButton(
                  songName: selectedSong ?? 'No Song Selected',
                  songId: _selectedSongID ?? 0,
                  userName: nameController.text,
                  score: _currentScore,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            NavigationButton(
              buttonText: 'Results',
              nextPage: ResultsPage(userName: currentUserName),
            ),
            ThemeSwitcherButton(),
            NavigationButton(
              buttonText: 'Favorites',
              nextPage: FavoritesPage(userName: currentUserName),
            ),
          ],
        ),
      ),
    );
  }
}
