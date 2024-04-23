import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'http_util.dart';

Future<void> submitVote({
  required BuildContext context,
  required String userName,
  required int songId,
  required double score,
  bool xSkip = false,
  final String? songName,
}) async {
  if (userName == null || userName.isEmpty) {
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
      'x_skip': xSkip,
    }),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vote with score $score submitted successfully for $songName'),
        duration: const Duration(seconds: 3),
      ),
    );
  } else {
    print('Failed to submit vote');
  }
}
