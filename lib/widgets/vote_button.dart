import 'package:euro_app/http_backend.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<void> _submitVote(BuildContext context) async {
    if (userName == null || userName.isEmpty) {
    // Show a Snackbar error message if the username is null or empty
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You must type in your name to submit a vote.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
    final response = await http.post(
      Uri.parse(votePostHTTP),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_name': userName,
        'song_id': songId,
        'score': score,
      }),
    );
    

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vote submitted successfully for $songName'),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      print('Failed to submit vote');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _submitVote(context),
      child: Text('Vote $score for $songName'),
    );
  }
}
