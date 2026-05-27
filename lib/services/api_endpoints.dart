import 'package:euro_app/config/runtime_config.dart';

String get apiBaseHTTP => RuntimeConfig.apiBaseHTTP;
String get apiBaseWS => RuntimeConfig.apiBaseWS;

String get songsHTTP => '$apiBaseHTTP/songs';
String get votePostHTTP => '$apiBaseHTTP/votepost';
String get voteGetHTTP => '$apiBaseHTTP/voteget';
String get favoriteAddHTTP => '$apiBaseHTTP/add_favorite';
String get favoriteRemoveHTTP => '$apiBaseHTTP/remove_favorite';
String get favoriteGetHTTP => '$apiBaseHTTP/get_favorites/';
String get websocketHTTP => apiBaseWS;
String get ioHTTP => apiBaseHTTP;
String get xCountUpdateHTTP => '$apiBaseHTTP/update_xcount';
String get xCountGetHTTP => '$apiBaseHTTP/get_xcount';
String get finalResultsHTTP => '$apiBaseHTTP/final_results';
