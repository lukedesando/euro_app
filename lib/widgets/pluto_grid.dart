import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class SongGrid extends StatefulWidget {
  final List<dynamic> songs;
  final Map<int, int> userVotes;

  const SongGrid({
    Key? key,
    required this.songs,
    required this.userVotes,
  }) : super(key: key);

  @override
  _SongGridState createState() => _SongGridState();
}

class _SongGridState extends State<SongGrid> {
  late PlutoGridStateManager stateManager;

  List<PlutoRow> generateRows() {
      return widget.songs.map((song) {
        return PlutoRow(
          cells: {
            'country': PlutoCell(value: song['country']),
            'song_name': PlutoCell(value: song['song_name']),
            'artist': PlutoCell(value: song['artist']),
            'average_score': PlutoCell(value: song['average_score'].toString()),
            'my_score': PlutoCell(value: widget.userVotes[song['song_id']]?.toString() ?? 'Not Voted'),  // This retrieves the score or shows 'Not Voted'
          }
        );
      }).toList();
    }

  @override
  Widget build(BuildContext context) {
    return PlutoGrid(
      columns: [
        PlutoColumn(title: 'Country', field: 'country', type: PlutoColumnType.text()),
        PlutoColumn(title: 'Song', field: 'song_name', type: PlutoColumnType.text()),
        PlutoColumn(title: 'Artist', field: 'artist', type: PlutoColumnType.text()),
        PlutoColumn(title: 'My Score', field: 'my_score', type: PlutoColumnType.text()), // Adding My Score column
        PlutoColumn(title: 'Average Score', field: 'average_score', type: PlutoColumnType.number(format: '#,###.###')),
      ],
      rows: generateRows(),
      onLoaded: (PlutoGridOnLoadedEvent event) {
        stateManager = event.stateManager;
      },
      onChanged: (PlutoGridOnChangedEvent event) {
        print(event);
      },
      configuration: PlutoGridConfiguration(
        // Customize your grid configuration
      ),
    );
  }
}
