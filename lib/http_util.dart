import 'config.dart';

String songsHTTP = 'http://${Config.DB_HOST}:${Config.DB_PORT}/songs';
String votePostHTTP = 'http://${Config.DB_HOST}:${Config.DB_PORT}/votepost';
String voteGetHTTP = 'http://${Config.DB_HOST}:${Config.DB_PORT}/voteget';
String favoriteAddHTTP = 'http://${Config.DB_HOST}:${Config.DB_PORT}/add_favorite';
String favoriteRemoveHTTP = 'http://${Config.DB_HOST}:${Config.DB_PORT}/remove_favorite';
String favoriteGetHTTP = 'http://${Config.DB_HOST}:${Config.DB_PORT}/get_favorites/';