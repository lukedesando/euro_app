import 'package:flutter/material.dart';
import '../vote_util.dart';

class VoteButton extends StatelessWidget {
  final String songName;
  final String userName;
  final double score;
  final int songId;

  const VoteButton({
    Key? key,
    required this.songName,
    required this.userName,
    required this.score,
    required this.songId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => submitVote(
        context: context,
        userName: userName,
        songId: songId,
        score: score,
        songName: songName),
      child: Text('Vote $score for $songName'),
    );
  }
}
