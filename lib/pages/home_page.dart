import 'package:flutter/material.dart';
import 'package:euro_app/global.dart';
import 'package:euro_app/models/x_count_model.dart';
import 'package:euro_app/services/socket_service.dart';
import 'package:provider/provider.dart';
import 'dart:async';

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
  const HomePage({super.key});

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
  bool _showGlitter = false;
  Timer? _glitterTimer;

  @override
  void initState() {
    super.initState();
    _socketService = SocketService();
    _socketService.createSocketConnection();
  }

  @override
  void dispose() {
    _glitterTimer?.cancel();
    nameController.dispose();
    _socketService.dispose();
    super.dispose();
  }

  Future<void> _onSongChanged(
      int id, String name, String country, int newXCount) async {
    setState(() {
      _selectedSongID = id;
      selectedSong = name;
      selectedCountry = country;
      Global.songSelection.setSelectedSongId(id);
    });

    await Global.xCountModel.initializeXCount(id);
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
    setState(() {
      _showGlitter = true; // Show glitter effect
    });
    _glitterTimer?.cancel();
    _glitterTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() {
        _showGlitter = false;
      });
    });
  }

  void _onXButtonPressed() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarEuro(title: 'Vote for Eurovision Song'),
      body: Stack(
        children: [
          _buildContent(),
          if (_showGlitter)
            GlitterBox(
              child:
                  Container(), // Empty container since GlitterBox is an effect overlay
            ),
        ],
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
              nextPage: FavoritesPage(userName: nameController.text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
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
            userName: nameController.text,
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
            child: Consumer<XCountModel>(
              builder: (context, xCountModel, child) {
                return Text('Votes to Skip: ${xCountModel.xCount}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
