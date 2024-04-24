import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'http_util.dart';

bool _isSnackbarActive = false;

void showCustomSnackbar(String message, BuildContext context, {Color? backgroundColor}) {
  if (!_isSnackbarActive) {
    _isSnackbarActive = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor ?? Theme.of(context).snackBarTheme.backgroundColor,  // Use the provided color
      ),
    ).closed.then((reason) {
      _isSnackbarActive = false; // Reset the flag when Snackbar is closed
    });
  }
}

Future<void> submitVote({
  required BuildContext context,
  required String country,
  required String userName,
  required int songId,
  required double score,
  bool xSkip = false,
  final String? songName,
}) async {
  if (userName.isEmpty) {
    showCustomSnackbar('You must type in your name to submit a vote.', context, backgroundColor: Colors.red);
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
    String successMessage = 'Vote with score $score submitted successfully for $country';
    showCustomSnackbar(successMessage, context);
  } else {
    print('Failed to submit vote'); // Consider using showCustomSnackbar for error handling too
  }
}
