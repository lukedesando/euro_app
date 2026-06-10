import 'dart:convert';
import 'package:euro_app/widgets/buttons/spotify_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flag/flag.dart';
import 'package:euro_app/widgets/buttons/theme_switch_button.dart';
import 'package:euro_app/styles/style.dart';
import '../services/api_endpoints.dart';

class FavoritesPage extends StatefulWidget {
  final String? userName;

  const FavoritesPage({super.key, this.userName});

  @override
  FavoritesPageState createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {
  List<dynamic> favoriteSongs = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchFavoriteSongs();
  }

  @override
  void didUpdateWidget(FavoritesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userName != oldWidget.userName) {
      fetchFavoriteSongs();
    }
  }

  Future<void> fetchFavoriteSongs() async {
    final userName = widget.userName?.trim() ?? '';
    if (userName.isEmpty) {
      setState(() {
        favoriteSongs = [];
        isLoading = false;
        errorMessage = 'Enter your name before viewing favorites.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final url = Uri.parse(
      '$favoriteGetHTTP/${Uri.encodeComponent(userName)}',
    );

    try {
      final response = await http.get(url);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          favoriteSongs = decoded is List ? decoded : [];
          isLoading = false;
          errorMessage =
              decoded is List ? null : 'Favorites response was not a list.';
        });
      } else {
        setState(() {
          favoriteSongs = [];
          isLoading = false;
          errorMessage =
              'Could not load favorites (${response.statusCode}). Please try again.';
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        favoriteSongs = [];
        isLoading = false;
        errorMessage = 'Could not load favorites: $error';
      });
    }
  }

  Widget _buildMessage(String message, {bool showUser = false}) {
    final userName = widget.userName?.trim() ?? '';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (showUser) ...[
              const SizedBox(height: 12),
              Text(
                'Looking up favorites for: ${userName.isEmpty ? '(no name entered)' : userName}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: fetchFavoriteSongs,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return _buildMessage(errorMessage!, showUser: true);
    }

    if (favoriteSongs.isEmpty) {
      return _buildMessage('No favorites yet.');
    }

    return ListView.builder(
      itemCount: favoriteSongs.length,
      itemBuilder: (context, index) {
        final song = favoriteSongs[index];
        final countryCode = song['country_code'] == 'Unknown'
            ? 'UN'
            : song['country_code'] ?? 'UN';

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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchFavoriteSongs,
          ),
          const LogoBlackandWhite(),
        ],
      ),
      body: _buildBody(),
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
