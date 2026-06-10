import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:euro_app/services/api_endpoints.dart';

class FavoriteButton extends StatefulWidget {
  final int songId;
  final String userName;

  const FavoriteButton({
    Key? key,
    required this.songId,
    required this.userName,
  }) : super(key: key);

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorited = false;
  int _favoriteCheckRequest = 0;

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.songId != oldWidget.songId ||
        widget.userName != oldWidget.userName) {
      _checkIfFavorited();
    }
  }

  Future<void> _checkIfFavorited() async {
    final requestId = ++_favoriteCheckRequest;
    final songId = widget.songId;
    final userName = widget.userName.trim();
    if (userName.isEmpty || songId == 0) {
      setState(() {
        _isFavorited = false;
      });
      return;
    }

    try {
      final url = Uri.parse('$favoriteGetHTTP/${Uri.encodeComponent(userName)}');
      final response = await http.get(url);
      if (!mounted ||
          requestId != _favoriteCheckRequest ||
          songId != widget.songId ||
          userName != widget.userName.trim()) {
        return;
      }

      if (response.statusCode == 200) {
        List<dynamic> favoritesJson = json.decode(response.body);
        List<int> favoriteSongIds =
            favoritesJson.map((fav) => fav['song_id'] as int).toList();
        setState(() {
          _isFavorited = favoriteSongIds.contains(songId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not check favorite (${response.statusCode}).'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (!mounted ||
          requestId != _favoriteCheckRequest ||
          songId != widget.songId ||
          userName != widget.userName.trim()) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not check favorite: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleFavorite() async {
    final songId = widget.songId;
    final userName = widget.userName.trim();
    if (userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You must type in your name to favorite a song.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (songId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Select a song before favoriting.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final url = _isFavorited
        ? Uri.parse(favoriteRemoveHTTP)
        : Uri.parse(favoriteAddHTTP);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_name': userName,
          'song_id': songId,
        }),
      );

      if (!mounted ||
          songId != widget.songId ||
          userName != widget.userName.trim()) {
        return;
      }

      if (response.statusCode == 200) {
        await _checkIfFavorited();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Could not update favorite (${response.statusCode}).'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update favorite: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_isFavorited ? Icons.favorite : Icons.favorite_border),
      color: Colors.red,
      onPressed: _toggleFavorite,
    );
  }
}

class FavoritesList extends StatelessWidget {
  final String userName;

  const FavoritesList({Key? key, required this.userName}) : super(key: key);

  Future<List<int>> _fetchFavorites() async {
    final url = Uri.parse(
      '$favoriteGetHTTP/${Uri.encodeComponent(userName.trim())}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> favoritesJson = json.decode(response.body);
      return favoritesJson.map((fav) => fav['song_id'] as int).toList();
    } else {
      // Handle error
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: _fetchFavorites(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<int> favorites = snapshot.data!;
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Song ID: ${favorites[index]}'),
                // You can replace this with more detailed information about the song
              );
            },
          );
        }
      },
    );
  }
}
