import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:http/http.dart' as http; // Import the http package
import 'package:euro_app/http_util.dart';
import 'dart:convert';

class XCountModel extends ChangeNotifier {
    int _xCount = 0;
    int get xCount => _xCount;
    bool _initialized = false;


    void initialize(int songId) {
        if (!_initialized) {
            initializeXCount(songId);
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

    void updateXCount(int newCount) {
        print("Trying to update xCount from $_xCount to $newCount");
        if (_xCount != newCount) {
            _xCount = newCount;
            notifyListeners();  // Notifies listeners about changes
            print("XCountModel updated: $_xCount");
        } else {
            print("No update needed as the value is the same");
        }
    }
}
