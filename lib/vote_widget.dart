import 'package:flutter/material.dart';

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