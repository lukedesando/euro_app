import 'package:flutter/material.dart';
import 'vote_widget.dart';

class VotingSlider extends StatelessWidget {
  final double score;
  final Function(double) onChanged;

  const VotingSlider({
    Key? key,
    required this.score,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VoteWidget(
      child: Column(
        children: <Widget>[
          Text('Score:'),
          Slider(
            value: score,
            onChanged: onChanged,
            min: 0,
            max: 10,
            divisions: 10,
            label: score.toStringAsFixed(1),
          ),
        ],
      ),
    );
  }
}