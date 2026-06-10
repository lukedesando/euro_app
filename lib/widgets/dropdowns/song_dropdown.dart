import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flag/flag.dart';
import 'package:euro_app/global.dart';
import '../../services/api_endpoints.dart';
import '../buttons/favorite_button.dart';

class SongDropdown extends StatefulWidget {
  final Function(int, String, String, int) onSongSelected;
  final int songId;
  final String userName;
  final int xCount;

  const SongDropdown({
    super.key,
    required this.onSongSelected,
    required this.songId,
    required this.userName,
    required this.xCount,
  });

  @override
  State<SongDropdown> createState() => _SongDropdownState();
}

class _SongDropdownState extends State<SongDropdown> {
  List<dynamic> songs = [];
  String? _selectedSong;
  late int _selectedSongId;

  Map<String, dynamic> displayInfo = {
    'country': '',
    'song_name': '',
    'artist': '',
    'x_count': 0,
  };
  String displaySelection =
      'country'; // Options: 'country', 'song_name', 'artist'

  @override
  void initState() {
    super.initState();
    _selectedSongId = widget.songId;
    fetchSongs();
  }

  @override
  void didUpdateWidget(SongDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.songId != oldWidget.songId) {
      _selectedSongId = widget.songId;
    }
  }

  Future<void> fetchSongs() async {
    final url = Uri.parse(songsHTTP);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        songs = json.decode(response.body);
        songs.sort(
          (a, b) => a['country'].compareTo(b['country']),
        );
      }); // Sort the list by country name.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            displaySelection == 'country' &&
                    displayInfo['country'] != '' &&
                    displayInfo['country_code'] != 'Unknown'
                ? Flag.fromString(
                    displayInfo['country_code'] ?? '',
                    height: 50,
                    width: 65,
                  )
                : const SizedBox.shrink(),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Song is: ${displayInfo['song_name'] ?? ''}',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: _selectedSong,
                isExpanded: true,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                underline: Container(
                  height: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onChanged: (String? newValue) {
                  if (newValue == null) return;
                  setState(() {
                    _selectedSong = newValue;
                    var selectedSong = songs.firstWhere(
                      (song) => song[displaySelection] == newValue,
                      orElse: () => <String, dynamic>{},
                    );
                    if (selectedSong.isNotEmpty) {
                      _selectedSong = newValue;
                      _selectedSongId = selectedSong['song_id'];
                      // updateDisplayInfo(selectedSong);
                      Global.songSelection
                          .setSelectedSongId(selectedSong['song_id']);
                    }
                    displayInfo['country'] = selectedSong['country'] ?? '';
                    displayInfo['song_name'] = selectedSong['song_name'] ?? '';
                    displayInfo['artist'] = selectedSong['artist'] ?? '';
                    displayInfo['country_code'] =
                        selectedSong['country_code'] ?? '';
                    displayInfo['x_count'] = selectedSong['x_count'] ?? 0;
                    widget.onSongSelected(
                        selectedSong['song_id'],
                        selectedSong['song_name'],
                        selectedSong['country'],
                        selectedSong['x_count']);
                  });
                },
                items: songs.map<DropdownMenuItem<String>>((dynamic song) {
                  final label = song[displaySelection] as String;
                  return DropdownMenuItem<String>(
                    value: label,
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 8),
            FavoriteButton(
              key: ValueKey('favorite-${widget.userName}-$_selectedSongId'),
              songId: _selectedSongId,
              userName: widget.userName,
            ),
          ],
        ),
      ],
    );
  }
}
