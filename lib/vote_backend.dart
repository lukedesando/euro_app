import 'package:flutter/material.dart';
import 'config.dart';

String songsHTTP = 'http://${Config.DB_HOST}:${Config.DB_PORT}/songs';
String voteHTTP = 'http://${Config.DB_HOST}:${Config.DB_PORT}/vote';

class VoteWidget extends StatelessWidget {
  final Widget child;
  
  const VoteWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}