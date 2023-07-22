import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/Main/bottom_navbar_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:to_do_list_app/Main/bottom_navbar_provider.dart';

Future<bool> locationPermissionAndServicesEnabled() async {
  bool serviceEnabled;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled, handle it accordingly
    return false;
  }

  // Check location permission status
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied &&
      permission == LocationPermission.deniedForever) {
    // Location permissions are denied, ask for permission
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      // Location permissions are not granted, handle it accordingly
      return false;
    }
  }

  return true;
}

Future<Position> getCurrentLocation(context) async {
  Position position;
  bool locationPermissionAndServicesStatus =
      await locationPermissionAndServicesEnabled();
  if (!locationPermissionAndServicesStatus) {
    showPopUp(context);
    position = Position(
      latitude: -180,
      longitude: -180,
      speed: 0,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speedAccuracy: 0,
      timestamp: DateTime.now(),
    );
  } else {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10));
    // Provider.of<BottomNavBarProvider>(context, listen: false)
    //     .isLocationServicesAvailable
    //     .value = true;
  }
  return position;
}

void showPopUp(context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Location Services Or Permissions Disabled'),
      content: const Text(
          'Please enable both location services and permissions to use this feature.'),
      actions: [
        TextButton(
          child: const Text('Open Settings'),
          onPressed: () {
            // Open device settings
            Geolocator.openAppSettings();
            Navigator.of(context).pop();
            Provider.of<BottomNavBarProvider>(context, listen: false)
                .currentIndex
                .value = 0;
          },
        ),
      ],
    ),
  );
}
