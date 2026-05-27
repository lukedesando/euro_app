import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:euro_app/services/api_endpoints.dart';
import 'package:euro_app/global.dart';

class SocketService {
  io.Socket? _socket;

  SocketService();

  void createSocketConnection() {
    if (_socket != null) return;

    final socket = io.io(
        ioHTTP,
        io.OptionBuilder()
            .setTransports(['websocket']) // Use WebSocket transport
            .build());
    _socket = socket;

    socket.onConnect((_) {
      print('Connected to server via WebSocket.');
    });

    socket.on('x_count_update', (data) {
      print('Received x_count_update (socket on): $data');
      if (data is String) {
        data = jsonDecode(data);
      }
      int songId = data['song_id'];
      int xCount = data['x_count'];
      if (Global.songSelection.selectedSongId == songId) {
        Global.xCountModel.setXCountFromServer(xCount);
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
        Global.xCountModel.setXCountFromServer(xCount);
        print("Updated xCount for song ID $songId to $xCount.");
      }
    } catch (e) {
      print('Error decoding JSON or updating state: $e');
    }
  }

  void dispose() {
    final socket = _socket;
    if (socket == null) return;

    if (socket.connected) {
      socket.disconnect();
    }
    socket.dispose();
    _socket = null;
    print("Socket disposed.");
  }
}
