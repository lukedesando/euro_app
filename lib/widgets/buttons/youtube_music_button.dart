import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class YouTubeMusicButton extends StatelessWidget {
  final String songName;
  final String artistName;
  final String imageUrl;

  const YouTubeMusicButton({
    super.key,
    required this.songName,
    required this.artistName,
    this.imageUrl = 'assets/images/youtube_music_logo.png',
  });

  Future<void> _launchYouTubeMusicSearch() async {
    final query = Uri.encodeQueryComponent('$artistName $songName');
    final url = Uri.parse('https://music.youtube.com/search?q=$query');

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
      iconSize: 24,
      padding: const EdgeInsets.all(8),
      onPressed: _launchYouTubeMusicSearch,
    );
  }
}
