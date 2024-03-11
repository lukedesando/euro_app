import 'package:flutter/material.dart';
import 'package:dotenv/dotenv.dart' as dotenv;

void main() {
  dotenv.load(); // Load the .env file
}

String DB_HOST = dotenv.env['DB_HOST'] ?? 'localhost';
// String songsHTTP = 'http://${DB_HOST}:5000/songs';
const String songsHTTP = 'http://localhost:5000/songs';
const String voteHTTP = 'http://localhost:5000/vote';

class VoteWidget extends StatelessWidget {
  final Widget child;

  const VoteWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}