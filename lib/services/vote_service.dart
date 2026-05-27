import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api_endpoints.dart';

bool _isSnackbarActive = false;

void showCustomSnackbar(String message, BuildContext context,
    {Color? backgroundColor}) {
  if (!_isSnackbarActive) {
    _isSnackbarActive = true;
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: backgroundColor ??
                Theme.of(context)
                    .snackBarTheme
                    .backgroundColor, // Use the provided color
          ),
        )
        .closed
        .then((reason) {
      _isSnackbarActive = false; // Reset the flag when Snackbar is closed
    });
  }
}

Future<bool> submitVote({
  required BuildContext context,
  required String country,
  required String userName,
  required int songId,
  required double score,
  bool xSkip = false,
  final String? songName,
}) async {
  if (userName.isEmpty) {
    showCustomSnackbar('You must type in your name to submit a vote.', context,
        backgroundColor: Colors.red);
    return false;
  }

  final response = await http.post(
    Uri.parse(votePostHTTP),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'user_name': userName,
      'score': score.toInt(),
      'song_id': songId,
      'x_skip': xSkip,
    }),
  );

  if (!context.mounted) return false;

  if (response.statusCode == 200) {
    String successMessage =
        'Vote with score $score submitted successfully for $country';
    showCustomSnackbar(successMessage, context);
    return true;
  } else {
    showCustomSnackbar('Failed to submit vote.', context,
        backgroundColor: Colors.red);
    return false;
  }
}
