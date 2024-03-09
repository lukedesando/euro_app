import 'package:flutter/material.dart';
import 'vote_widget.dart';

class SaveVoteButton extends StatelessWidget {
  final Function(String) saveVote;
  final String selectedSong;

  const SaveVoteButton({
    Key? key,
    required this.saveVote,
    required this.selectedSong,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VoteWidget(
      child: ElevatedButton(
        onPressed: () => saveVote(selectedSong),
        child: Text('Save Vote'),
      ),
    );
  }
}