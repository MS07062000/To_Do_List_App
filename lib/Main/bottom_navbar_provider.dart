import 'package:flutter/material.dart';

class BottomNavBarProvider extends ChangeNotifier {
  ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
}
