import 'package:flutter/material.dart';
import 'package:euro_app/Global.dart';
import 'package:euro_app/models/x_count_model.dart';
import 'package:euro_app/services/socket_service.dart';
import 'package:provider/provider.dart';

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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedSong;
  double _currentScore = 5.0; // Default score
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
      // Update the global selectedSongId
      Global.songSelection.setSelectedSongId(id);
      setState(() {
      // Trigger Consumer update
      });
    });

    // Fetch and initialize xCount from the database
    Global.xCountModel.initializeXCount(id).then((_) {
      setState(() {
        // Force a rebuild to ensure the correct xCount is displayed
      });
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

  void _onVoteButtonPressed() {
    // Update the xCountModel after voting
    setState(() {
      // Trigger Consumer update
    });
  }

  void _onXButtonPressed() {
    // Update the xCountModel after voting
    setState(() {
      // Trigger Consumer update
    });
  }

  void _xCountUpdated() {
    // Update the xCountModel after voting
    setState(() {
      // Trigger Consumer update
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarEuro(title: 'Vote for Eurovision Song'),
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
              const SizedBox(height: 20),
              const Text('Select Country:'),
              SongDropdown(
                onSongSelected: _onSongChanged,
                songId: _selectedSongID ?? 0,
                userName: currentUserName ?? '',
                x_count: Global.xCountModel.xCount, // Use global x_count
              ),
              const SizedBox(height: 20),
              ScoreSlider(onScoreChanged: _onScoreChanged),
              const SizedBox(height: 20),
              Center(
                child: VoteButton(
                  songName: selectedSong ?? 'No Song Selected',
                  songId: _selectedSongID ?? 0,
                  userName: nameController.text,
                  score: _currentScore,
                  country: selectedCountry ?? 'No Country Selected',
                  onUpdate: _onVoteButtonPressed,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: XButton(
                  songName: selectedSong ?? 'No Song Selected',
                  songId: _selectedSongID ?? 0,
                  userName: nameController.text,
                  score: _currentScore,
                  country: selectedCountry ?? 'No Country Selected',
                  onUpdate: _onXButtonPressed,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: FutureBuilder<void>(
                  future: Global.xCountModel.initializeXCount(_selectedSongID ?? 0),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error loading xCount');
                    } else {
                      return Consumer<XCountModel>(
                        builder: (context, xCountModel, child) {
                          return Text('Votes to Skip: ${xCountModel.xCount}');
                        },
                      );
                    }
                  },
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
