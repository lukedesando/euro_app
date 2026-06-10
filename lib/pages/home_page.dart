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
  State<HomePage> createState() => _HomePageState();
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
          Positioned.fill(child: _buildContent()),
          if (_showGlitter)
            GlitterBox(
              child:
                  const SizedBox.shrink(), // Empty child since GlitterBox is an effect overlay
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: [
              NavigationButton(
                buttonText: 'Results',
                nextPage: ResultsPage(userName: currentUserName),
              ),
              const SizedBox(width: 12),
              const ThemeSwitcherButton(),
              const SizedBox(width: 12),
              NavigationButton(
                buttonText: 'Favorites',
                nextPage: FavoritesPage(userName: nameController.text),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final screenHeight = MediaQuery.of(context).size.height;
    final compactSpacing = screenHeight <= 560;
    final sectionSpacing = compactSpacing ? 12.0 : 20.0;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          NameInputField(
            controller: nameController,
            onNameChanged: _onNameChanged,
          ),
          SizedBox(height: sectionSpacing),
          const Text('Select Country:'),
          SongDropdown(
            onSongSelected: _onSongChanged,
            songId: _selectedSongID ?? 0,
            userName: nameController.text,
            xCount: Global.xCountModel.xCount,
          ),
          SizedBox(height: sectionSpacing),
          ScoreSlider(onScoreChanged: _onScoreChanged),
          SizedBox(height: sectionSpacing),
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
          SizedBox(height: sectionSpacing),
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
          SizedBox(height: sectionSpacing),
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
