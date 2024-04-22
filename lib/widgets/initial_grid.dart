import 'package:flutter/material.dart';
import 'package:flag/flag.dart';

class InitialGrid extends StatelessWidget {
  final List<dynamic> songs;
  final Map<int, int> userVotes;
  final bool showUnvotedOnly;
  final double flagHeight;

  InitialGrid({
    Key? key,
    required this.songs,
    required this.userVotes,
    required this.showUnvotedOnly,
    this.flagHeight = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        if (showUnvotedOnly && userVotes.containsKey(song['song_id'])) {
          return SizedBox.shrink(); // Don't show voted songs
        }
        return ListTile(
          title: Text('${song['country']}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${song['song_name']}'),
              Text('by ${song['artist']}'),
              Text('My Score: ${userVotes[song['song_id']] ?? "Not Voted"}'),
              Text('Average Score: ${song['average_score']}'),
            ],
          ),
          leading: Flag.fromString(
            song['country_code'] ?? '',
            height: flagHeight,
            width: flagHeight * 1.5,
          ),
        );
      },
    );
  }
}
