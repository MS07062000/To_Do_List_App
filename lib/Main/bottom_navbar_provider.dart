import 'package:flutter/material.dart';

class BottomNavBarProvider extends ChangeNotifier {
  ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
  // ValueNotifier<bool> refreshNotifier = ValueNotifier<bool>(false);
  // ValueNotifier<bool> isNotesAvailable = ValueNotifier<bool>(false);
  // ValueNotifier<bool> isLocationServicesAvailable = ValueNotifier<bool>(false);
  // ValueNotifier<ActionStateValue> actionStateValue =
  //     ValueNotifier<ActionStateValue>(
  //   ActionStateValue(
  //     currentIndex: 0,
  //     isNotesAvailable: false,
  //     isLocationServicesAvailable: false,
  //   ),
  // );
  // ValueNotifier<String> sortBy = ValueNotifier<String>('');
  // List<dynamic> _notesKeys = [];
  // List<dynamic> get noteKeys => _notesKeys;

  // void setNotesKeys(List<dynamic> noteKeys) {
  //   _notesKeys = noteKeys;
  //   notifyListeners();
  // }

  // void setActionStateValue(ActionStateValue actionStateValueChange) {
  //   actionStateValue.value = ActionStateValue(
  //       currentIndex: actionStateValueChange.currentIndex,
  //       isNotesAvailable: actionStateValueChange.isNotesAvailable,
  //       isLocationServicesAvailable:
  //           actionStateValueChange.isLocationServicesAvailable);
  //   notifyListeners();
  // }
}

// class ActionStateValue {
//   final bool isNotesAvailable;
//   final bool isLocationServicesAvailable;
//   final int currentIndex;

//   ActionStateValue({
//     required this.isNotesAvailable,
//     required this.isLocationServicesAvailable,
//     required this.currentIndex,
//   });
// }
