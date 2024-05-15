import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:http/http.dart' as http; // Import the http package
import 'package:euro_app/http_util.dart';
import 'dart:convert';

class XCountModel extends ChangeNotifier {
  static int _xCount = 0;
  int get xCount => _xCount;
  bool _initialized = false;
  Timer? _pollingTimer;

  void initialize(int songId) {
    if (!_initialized) {
      initializeXCount(songId);
      startPolling(songId);
      _initialized = true;  // Prevent re-initialization
    }
  }

  Future<void> initializeXCount(int songId) async {
    try {
      var url = Uri.parse('$xCountGetHTTP/$songId');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        _xCount = data['x_count'];
        notifyListeners();  // This method updates the UI and other listeners
        print("XCountModel initialized: $_xCount");
      } else {
        print('Failed to fetch initial x_count with status: ${response.statusCode}.');
      }
    } catch (e) {
      print("Failed to fetch initial x_count: $e");
    }
  }

  void updateXCount(int newCount, int songId) {
    print("Trying to update xCount from $_xCount to $newCount");
    if (_xCount != newCount) {
      _xCount = newCount;
      print("XCountModel updated: $_xCount");
      notifyListeners();
    } else {
      print("No update needed as the value is the same");
    }
    sendUpdateToServer(newCount, songId);
  }

  Future<void> sendUpdateToServer(int newCount, int songId) async {
    try {
      var url = Uri.parse(xCountUpdateHTTP);  // Your server URL
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'song_id': songId,
          'new_x_count': newCount,
        }),
      );

      if (response.statusCode == 200) {
        print("Server updated successfully.");
      } else {
        print("Failed to update server. Status code: ${response.statusCode}. Response: ${response.body}");
      }
    } catch (e) {
      print("Failed to send update to server: $e");
    }
  }

  void startPolling(int songId) {
    _pollingTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      try {
        var url = Uri.parse('$xCountGetHTTP/$songId');
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          int newXCount = data['x_count'];
          if (_xCount != newXCount) {
            updateXCount(newXCount, songId);
          }
        } else {
          print('Failed to fetch x_count with status: ${response.statusCode}.');
        }
      } catch (e) {
        print("Failed to fetch x_count: $e");
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
