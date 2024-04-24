import 'package:flutter/material.dart';
import '../vote_util.dart';

class VoteButton extends StatelessWidget {
  final String songName;
  final String userName;
  final double score;
  final int songId;
  final String country;

  const VoteButton({
    Key? key,
    required this.songName,
    required this.userName,
    required this.score,
    required this.songId,
    required this.country,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => submitVote(
        context: context,
        userName: userName,
        songId: songId,
        score: score,
        songName: songName,
        country: country,
        ),
      child: Text('Vote $score for $country'),
    );
  }
}
