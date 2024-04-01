import 'config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String songsHTTP = 'http://${Config.DB_HOST}:${Config.DB_PORT}/songs';
String votePostHTTP = 'http://${Config.DB_HOST}:${Config.DB_PORT}/votepost';
String voteGetHTTP = 'http://${Config.DB_HOST}:${Config.DB_PORT}/voteget';
