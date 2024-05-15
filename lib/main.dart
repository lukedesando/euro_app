import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'widgets/buttons/theme_switch_button.dart';
import 'models/x_count_model.dart';

import 'package:euro_app/pages/home_page.dart';
import 'global.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:euro_app/http_util.dart';
import 'package:euro_app/services/socket_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider<XCountModel>(
          create: (context) => Global.xCountModel,
        ),
        ChangeNotifierProvider<SongSelection>(
          create: (context) => Global.songSelection,
        ),
      ],
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Eurovision Voting App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      home: HomePage(),
    );
  }
}

class WebSocket extends StatefulWidget{
  @override
  _WebSocketState createState() => _WebSocketState();
}

class _WebSocketState extends State<WebSocket>{
  final WebSocketChannel channel = IOWebSocketChannel.connect(websocketHTTP);

@override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            SocketService().handleXCountUpdate(snapshot.data);
            }
          return Text(snapshot.data.toString());
        },
      ),
    );
    
  }

}