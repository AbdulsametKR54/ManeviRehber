import 'package:flutter/material.dart';

class LocationManager extends ChangeNotifier {
  static final LocationManager _instance = LocationManager._internal();
  factory LocationManager() => _instance;
  LocationManager._internal();

  void notifyChange() {
    notifyListeners();
  }
}
