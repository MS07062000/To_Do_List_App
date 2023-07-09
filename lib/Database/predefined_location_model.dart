import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

Future<void> initializeHive() async {
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
}

Future<dynamic> addLocation(String userDefinedLocationName, String locationName,
    String coordinates) async {
  await initializeHive();

  final predefinedLocationBox = await Hive.openBox<Map>('PredefinedLocation');

  predefinedLocationBox.put(userDefinedLocationName,
      {'locationName': locationName, 'destinationCoordinates': coordinates});
}

Future<dynamic> deleteLocation(String userDefinedLocationName) async {
  await initializeHive();

  final predefinedLocationBox = await Hive.openBox<Map>('PredefinedLocation');

  predefinedLocationBox.delete(userDefinedLocationName);
}

Future<Map<dynamic, Map>> getPredefinedLocations() async {
  await initializeHive();

  final predefinedLocationBox = await Hive.openBox<Map>('PredefinedLocation');

  return predefinedLocationBox.toMap();
}

Future<String> getLocationInfo(String locationName) async {
  await initializeHive();

  final predefinedLocationBox = await Hive.openBox<Map>('PredefinedLocation');
  final locationList =
      predefinedLocationBox.keys.where((userDefinedLocationName) {
    return predefinedLocationBox
        .get(userDefinedLocationName.toString())!
        .containsValue(locationName);
  });

  if (locationList.isNotEmpty) {
    return locationList.first.toString();
  }
  return '';
}
