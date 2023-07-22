import 'package:location/location.dart';

Future<bool> locationPermissionAndServicesEnabled() async {
  bool serviceEnabled;
  serviceEnabled = await Location().serviceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled, handle it accordingly
    serviceEnabled = await Location().requestService();
    if (!serviceEnabled) {
      return false;
    }
    return false;
  }

  // Check location permission status
  PermissionStatus permission = await Location().hasPermission();
  if (permission == PermissionStatus.denied ||
      permission == PermissionStatus.deniedForever) {
    // Location permissions are denied, ask for permission
    permission = await Location().requestPermission();
    if (permission != PermissionStatus.granted) {
      // Location permissions are not granted, handle it accordingly
      return false;
    }
  }
  return true;
}

