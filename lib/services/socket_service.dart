import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:euro_app/http_util.dart';
import 'package:euro_app/global.dart';

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
        .disableAutoConnect()         // Disable auto-connect
        .build()
    );

    socket.connect();

    socket.on('x_count_update', (data) {
      print('Received x_count_update: $data');
      try {
        if (data is String) {
          data = jsonDecode(data);
        }
        int songId = data['song_id'];
        int xCount = data['x_count'];
        Global.xCountModel.updateXCount(xCount);
      } catch (e) {
        print('Error decoding JSON or updating state: $e');
      }
    });

    socket.onDisconnect((_) {
      print('Disconnected from server.');
    });
  }

  void dispose() {
    socket.disconnect();
    socket.dispose();
  }
}
