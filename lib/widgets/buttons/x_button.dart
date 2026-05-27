import 'package:flutter/material.dart';
import '../../services/vote_service.dart';

class XButton extends StatelessWidget {
  final String songName;
  final String userName;
  final double score;
  final int songId;
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          final submitted = await submitVote(
            context: context,
            userName: userName,
            songId: songId,
            score: 0,
            songName: songName,
            xSkip: true,
            country: country,
          );
          if (submitted) {
            onUpdate();
          }
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
