import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:euro_app/vote_backend.dart';

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

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
  }
  
  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.songId != oldWidget.songId) {
      _checkIfFavorited();
    }
  }
  
  void _checkIfFavorited() async {
    final url = Uri.parse('$favoriteGetHTTP/${widget.userName}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> favoritesJson = json.decode(response.body);
      List<int> favoriteSongIds = favoritesJson.map((fav) => fav['song_id'] as int).toList();
      setState(() {
        _isFavorited = favoriteSongIds.contains(widget.songId);
      });
    } else {
      // Handle error
    }
  }

  void _toggleFavorite() async {
    final url = _isFavorited
        ? Uri.parse(favoriteRemoveHTTP)
        : Uri.parse(favoriteAddHTTP);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_name': widget.userName,
        'song_id': widget.songId,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _isFavorited = !_isFavorited;
      });
    } else {
      // Handle error
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
    final url = Uri.parse('$favoriteGetHTTP/${this.userName}');
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
