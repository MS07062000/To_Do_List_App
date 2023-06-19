import 'package:flutter/material.dart';

class BottomNavBarProvider with ChangeNotifier {
  ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
  ValueNotifier<bool> refreshNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> isNotesAvailable = ValueNotifier<bool>(false);
  ValueNotifier<bool> isLocationServicesAvailable = ValueNotifier<bool>(false);
  ValueNotifier<String> sortBy = ValueNotifier<String>('');
  List<dynamic> _notesKeys = [];
  List<dynamic> get noteKeys => _notesKeys;

  void setNotesKeys(List<dynamic> noteKeys) {
    _notesKeys = noteKeys;
    notifyListeners();
  }
}
