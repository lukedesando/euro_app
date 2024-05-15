import 'package:euro_app/models/x_count_model.dart';
import 'package:flutter/foundation.dart';

class Global {
  static final XCountModel xCountModel = XCountModel();
  static final SongSelection songSelection = SongSelection();
}

class SongSelection extends ChangeNotifier {
  int? _selectedSongId;

  int? get selectedSongId => _selectedSongId;

  void setSelectedSongId(int? id) {
    if (_selectedSongId != id) {
      _selectedSongId = id;
      notifyListeners();
    }
  }
}
