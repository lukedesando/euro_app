import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../vote_util.dart';
import 'package:euro_app/models/x_count_model.dart';
import 'package:euro_app/global.dart';

class XButton extends StatelessWidget {
  final String songName;
  final String userName;
  final double score;
  final int songId;
  final audioPlayer = AudioPlayer();
  final String country;
  final VoidCallback onUpdate;

  XButton({
    Key? key,
    required this.songName,
    required this.userName,
    required this.score,
    required this.songId,
    required this.country,
    required this.onUpdate,
  }) : super(key: key);

  void playSound() {
    audioPlayer.play(AssetSource('assets/sounds/buzzer.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
    child: ElevatedButton(
      onPressed: () {
        submitVote(
          context: context,
          userName: userName,
          songId: songId,
          score: 0,
          songName: songName,
          xSkip: true,
          country: country,
        );
        onUpdate();
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        disabledForegroundColor: Colors.red.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        elevation: 5.0,
        padding: EdgeInsets.zero,
      ),
      child: Align(
        alignment: Alignment.center,
        child: Icon(Icons.close, color: Colors.white, size: 40),
    ),
    ),
    );
  }
}
