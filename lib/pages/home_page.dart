import 'package:flutter/material.dart';
import 'package:euro_app/Global.dart';

import '../widgets/dropdowns/song_dropdown.dart';
import '../widgets/sliders/score_slider.dart';
import '../widgets/buttons/vote_button.dart';
import '../widgets/input_boxes/name_input.dart';
import '../widgets/buttons/nav_button.dart';
import '../widgets/buttons/theme_switch_button.dart';
import '../widgets/effects/glitter_box.dart';
import '../widgets/buttons/x_button.dart';

import '../styles/style.dart';
import 'package:euro_app/pages/results_page.dart';
import 'package:euro_app/pages/favorites_page.dart';

import 'package:euro_app/services/socket_service.dart';
import '../models/x_count_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedSong;
  double _currentScore = 5.0; //Default score
  int? _selectedSongID;
  String? currentUserName;
  String? selectedCountry;
  final TextEditingController nameController = TextEditingController();
  late final SocketService _socketService;

  @override
  void initState() {
    super.initState();
    _socketService = SocketService();
    _socketService.createSocketConnection();
  }

  // Callback function to update your app state
  void _updateXCount(int songId, int xCount) {
    if (_selectedSongID == songId) {
      print("Updating global x_count from ${Global.xCountModel.xCount} to $xCount");
      Global.xCountModel.updateXCount(xCount);
    } else {
      print("Received x_count for non-selected song ID");
    }
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }

  void _onSongChanged(int id, String name, String country, int newXCount) {
    setState(() {
      _selectedSongID = id;
      selectedSong = name;
      selectedCountry = country;
      // Update the global x_count from the selected song's count
      Global.xCountModel.updateXCount(newXCount);
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
                  onSongSelected: _onSongChanged,
                  songId: _selectedSongID ?? 0,
                  userName: currentUserName ?? '',
                  x_count: Global.xCountModel.xCount,  // Use global x_count
              ),
              SizedBox(height: 20),  
              ScoreSlider(onScoreChanged: _onScoreChanged), SizedBox(height: 20),
              Center(
                child: VoteButton(
                  songName: selectedSong ?? 'No Song Selected',
                  songId: _selectedSongID ?? 0,
                  userName: nameController.text,
                  score: _currentScore,
                  country: selectedCountry ?? 'No Country Selected',
                ),
              ), SizedBox(height: 20),
              Center(
                child: XButton(
                  songName: selectedSong ?? 'No Song Selected',
                  songId: _selectedSongID ?? 0,
                  userName: nameController.text,
                  score: _currentScore,
                  country: selectedCountry ?? 'No Country Selected',
                ),
              ),
              // Center(child: Text('Votes to Skip: $x_count'),)
              Center(
                child: Text('Votes to Skip: ${Global.xCountModel.xCount}'),
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
