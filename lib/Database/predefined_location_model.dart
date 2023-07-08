import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

Future<void> initializeHive() async {
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
}

Future<dynamic> addLocation(String locationName, String coordinates) async {
  await initializeHive();

  final predefinedLocationBox =
      await Hive.openBox<String>('PredefinedLocation');

  predefinedLocationBox.put(locationName, coordinates);
}

Future<dynamic> deleteLocation(String locationName) async {
  await initializeHive();

  final predefinedLocationBox =
      await Hive.openBox<String>('PredefinedLocation');

  predefinedLocationBox.delete(locationName);
}

Future<Map<dynamic, String>> getPredefinedLocations() async {
  await initializeHive();

  final predefinedLocationBox =
      await Hive.openBox<String>('PredefinedLocation');

  return predefinedLocationBox.toMap();
}

Future<String> getCoordinates(String locationName) async {
  await initializeHive();

  final predefinedLocationBox =
      await Hive.openBox<String>('PredefinedLocation');
  return predefinedLocationBox.get(locationName).toString();
}

Future<String> getLocation(String coordinates) async {
  await initializeHive();

  final predefinedLocationBox =
      await Hive.openBox<String>('PredefinedLocation');
  final locationList = predefinedLocationBox.keys.where((locationName) {
    return predefinedLocationBox
            .get(locationName.toString())!
            .compareTo(coordinates) ==
        0;
  });

  if (locationList.isNotEmpty) {
    return locationList.first.toString();
  }
  return '';
}
