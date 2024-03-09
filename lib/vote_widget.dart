import 'package:flutter/material.dart';

class VoteWidget extends StatelessWidget {
  final Widget child;

  const VoteWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}