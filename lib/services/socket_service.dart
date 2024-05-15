import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:euro_app/http_util.dart';
import 'package:euro_app/global.dart';
import 'package:euro_app/models/x_count_model.dart';

class SocketService {
  late IO.Socket socket;

  SocketService() {
    createSocketConnection();
  }

  void createSocketConnection() {
    socket = IO.io(
      ioHTTP,  // Ensure this is your correct server URL
      IO.OptionBuilder()
        .setTransports(['websocket']) // Use WebSocket transport
        // .enableAutoConnect()         // Disable auto-connect
        .build()
    );

   socket.onConnect((_) {
      print('Connected to server via WebSocket.');
      // socket.connect();  // Ensure the connection is established
    });

    socket.on('x_count_update', (data) {
      print('Received x_count_update (socket on): $data');
      if (data is String) {
        data = jsonDecode(data);
      }
      int songId = data['song_id'];
      int xCount = data['x_count'];
      if (Global.songSelection.selectedSongId == songId) {
        Global.xCountModel.updateXCount(xCount, songId);
      }
    });

    socket.onDisconnect((_) {
      print('Disconnected from server.');
    });
  }

  void handleXCountUpdate(dynamic data) {
    try {
      // Assuming data is already in the correct format as a Map
      int songId = data['song_id'];
      int xCount = data['x_count'];

      // Check if the updated song ID matches the currently selected song ID
      if (Global.songSelection.selectedSongId == songId) {
        Global.xCountModel.updateXCount(xCount, songId);
        print("Updated xCount for song ID $songId to $xCount.");
      }
    } catch (e) {
      print('Error decoding JSON or updating state: $e');
    }
  }

  void dispose() {
    if (socket.connected) {
      socket.disconnect();
    }
    socket.dispose();
    print("Socket disposed.");
  }
}
