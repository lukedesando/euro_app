import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class SpotifyButton extends StatelessWidget {
  final String songName;
  final String artistName;
  final String imageUrl;

  const SpotifyButton({
    super.key,
    required this.songName,
    required this.artistName,
    this.imageUrl = 'assets/images/spotify_logo.png',
  });

  Future<void> _launchSpotifySearch() async {
    String query = Uri.encodeComponent('$songName $artistName');
    Uri url = Uri.parse('https://open.spotify.com/search/$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset(imageUrl),
      iconSize: 24, // Adjust the size of the image/icon
      padding: const EdgeInsets.all(8), // Adjust the padding to control the overall size of the button
      onPressed: _launchSpotifySearch,
    );
  }
}
