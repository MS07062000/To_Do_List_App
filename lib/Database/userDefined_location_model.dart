import 'package:hive/hive.dart';
import 'dart:developer';
import 'package:path_provider/path_provider.dart' as path_provider;

Future<void> initializeHive() async {
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
}

Future<void> addLocation(String userDefinedLocationName, String locationName,
    String coordinates) async {
  await initializeHive();
  final predefinedLocationBox = await Hive.openBox<Map>('PredefinedLocation');

  await predefinedLocationBox.put(userDefinedLocationName,
      {'locationName': locationName, 'destinationCoordinates': coordinates});
}

Future<void> deleteLocation(String userDefinedLocationName) async {
  await initializeHive();
  log(userDefinedLocationName);
  final predefinedLocationBox = await Hive.openBox<Map>('PredefinedLocation');

  await predefinedLocationBox.delete(userDefinedLocationName);
}

Future<Map> getUserDefinedLocations() async {
  await initializeHive();

  final predefinedLocationBox = await Hive.openBox<Map>('PredefinedLocation');

  return predefinedLocationBox.toMap();
}

Future<Map> getLocationInfo(String coordinates) async {
  await initializeHive();

  final predefinedLocationBox = await Hive.openBox<Map>('PredefinedLocation');
  final locationList =
      predefinedLocationBox.keys.where((userDefinedLocationName) {
    return predefinedLocationBox
        .get(userDefinedLocationName.toString())!
        .containsValue(coordinates);
  });

  if (locationList.isNotEmpty) {
    return locationList.first;
  }
  return {};
}
