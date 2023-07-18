import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:tuple/tuple.dart';

Future<void> initializeHive() async {
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
}

Future<bool> addLocation(String userDefinedLocationName, String locationName,
    String coordinates) async {
  try {
    await initializeHive();
    final predefinedLocationBox = await Hive.openBox<Map>('PredefinedLocation');

    await predefinedLocationBox.put(userDefinedLocationName,
        {'locationName': locationName, 'destinationCoordinates': coordinates});

    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> deleteLocation(String userDefinedLocationName) async {
  try {
    await initializeHive();
    // log(userDefinedLocationName);
    final predefinedLocationBox = await Hive.openBox<Map>('PredefinedLocation');

    await predefinedLocationBox.delete(userDefinedLocationName);
    return true;
  } catch (_) {
    return false;
  }
}

Future<Tuple2<Map, bool>> getUserDefinedLocations() async {
  try {
    await initializeHive();

    final predefinedLocationBox = await Hive.openBox<Map>('PredefinedLocation');

    return Tuple2(predefinedLocationBox.toMap(), true);
  } catch (_) {
    return const Tuple2({}, false);
  }
}

Future<Tuple2<Map, bool>> getLocationInfo(String coordinates) async {
  try {
    await initializeHive();

    final predefinedLocationBox = await Hive.openBox<Map>('PredefinedLocation');
    final locationList =
        predefinedLocationBox.keys.where((userDefinedLocationName) {
      return predefinedLocationBox
          .get(userDefinedLocationName.toString())!
          .containsValue(coordinates);
    });

    if (locationList.isNotEmpty) {
      return Tuple2(predefinedLocationBox.get(locationList.first)!, true);
    }
    return const Tuple2({}, true);
  } catch (_) {
    return const Tuple2({}, false);
  }
}
