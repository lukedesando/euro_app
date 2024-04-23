import 'dart:convert';
import 'package:euro_app/widgets/spotify_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flag/flag.dart';
import 'package:euro_app/widgets/theme_switch_button.dart';
import 'package:euro_app/styles/style.dart';
import '../http_util.dart';

class FavoritesPage extends StatefulWidget {
  final String? userName;

  FavoritesPage({super.key, this.userName});

  @override
  FavoritesPageState createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {
  List<dynamic> favoriteSongs = [];

  @override
  void initState() {
    super.initState();
    if (widget.userName != null) {
      fetchFavoriteSongs(widget.userName!);
    }
  }

  Future<void> fetchFavoriteSongs(String userName) async {
    var url = Uri.parse('$favoriteGetHTTP/${widget.userName}');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        favoriteSongs = json.decode(response.body);
      });
    } else {
      // Handle server errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        centerTitle: true,
        actions: [const LogoBlackandWhite()],
      ),
      body: ListView.builder(
  itemCount: favoriteSongs.length,
  itemBuilder: (context, index) {
    final song = favoriteSongs[index];
    String countryCode = song['country_code'] ?? 'UN'; // Use a default value like 'UN' for undefined

    return ListTile(
      title: Text('${song['country']}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${song['song_name']} by ${song['artist']}'),
        ],
      ),
      leading: Flag.fromString(
        countryCode,
        height: 50,
        width: 75,
      ),
      trailing: SizedBox(
        width: 40, // Adjust the width as needed
        height: 40, // Adjust the height as needed
        child: SpotifyButton(
          songName: song['song_name'],
          artistName: song['artist'],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ThemeSwitcherButton(),
          ],
        ),
      ),
    );
  }
}
