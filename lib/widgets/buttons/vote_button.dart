import 'package:flutter/material.dart';
import '../../services/vote_service.dart';

class VoteButton extends StatelessWidget {
  final String songName;
  final String userName;
  final double score;
  final int songId;
  final String country;
  final VoidCallback onUpdate;

  const VoteButton({
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
    return ElevatedButton(
      onPressed: () async {
        final submitted = await submitVote(
          context: context,
          userName: userName,
          songId: songId,
          score: score,
          songName: songName,
          country: country,
        );
        if (submitted) {
          onUpdate();
        }
      },
      child: Text('Vote $score for $country'),
    );
  }
}
