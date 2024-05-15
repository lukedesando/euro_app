import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import '../buttons/theme_switch_button.dart';

class FinalsGrid extends StatefulWidget {
  final List<dynamic> songs;
  final Map<int, int> userVotes;

  const FinalsGrid({
    Key? key,
    required this.songs,
    required this.userVotes,
  }) : super(key: key);

  @override
  _SongGridState createState() => _SongGridState();
}

class _SongGridState extends State<FinalsGrid> {
  late PlutoGridStateManager stateManager;

  List<PlutoRow> generateRows() {
      return widget.songs.map((song) {
        return PlutoRow(
          cells: {
            'country': PlutoCell(value: song['country']),
            'total_points': PlutoCell(value: song['total_points'].toString()),
            'jury_points': PlutoCell(value: song['jury_points'].toString()),
            'televoting_points': PlutoCell(value: song['televoting_points'].toString()),
            'place': PlutoCell(value: song['place'].toString()),
            'average_score': PlutoCell(value: song['average_score'].toString()),
            'my_score': PlutoCell(value: widget.userVotes[song['song_id']]?.toString() ?? 'Not Voted'),  // This retrieves the score or shows 'Not Voted'
          }
        );
      }).toList();
    }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Theme(
      data: themeProvider.themeMode == ThemeMode.dark ? ThemeData.dark() : ThemeData.light(),
      child: PlutoGrid(
        columns: [
          PlutoColumn(title: 'Country', field: 'country', type: PlutoColumnType.text()),
          PlutoColumn(title: 'Total Points', field: 'total_points', type: PlutoColumnType.text()),
          PlutoColumn(title: 'Jury Points', field: 'jury_points', type: PlutoColumnType.text()),
          PlutoColumn(title: 'Televoting Points', field: 'televoting_points', type: PlutoColumnType.text()),
          PlutoColumn(title: 'Final Place', field: 'place', type: PlutoColumnType.text()),
          PlutoColumn(title: 'Average Score', field: 'average_score', type: PlutoColumnType.number(format: '#,###.###')),
          PlutoColumn(title: 'My Score', field: 'my_score', type: PlutoColumnType.text()),
        ],
        rows: generateRows(),
        onLoaded: (PlutoGridOnLoadedEvent event) {
          stateManager = event.stateManager;
        },
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
        configuration: themeProvider.themeMode == ThemeMode.dark 
            ? PlutoGridConfiguration.dark() 
            : PlutoGridConfiguration(),
      ),
    );
  }
}
