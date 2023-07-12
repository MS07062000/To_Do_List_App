import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

Color getRandomColor() {
  final random = Random();
  final r = random.nextInt(256);
  final g = random.nextInt(256);
  final b = random.nextInt(256);

  return Color.fromARGB(255, r, g, b);
}

Future<bool> locationPermissionAndServicesEnabled() async {
  // bool serviceEnabled;
  // serviceEnabled = await Location().serviceEnabled();
  // if (!serviceEnabled) {
  //   // Location services are not enabled, handle it accordingly
  //   serviceEnabled = await Location().requestService();
  //   if (!serviceEnabled) {
  //     return false;
  //   }
  // }

  // Check location permission status
  return Location().hasPermission().then((permissionStatus) async {
    if (permissionStatus != PermissionStatus.granted) {
      // Location permissions are denied, ask for permission
      final permission = await Location().requestPermission();
      if (permission != PermissionStatus.granted) {
        // Location permissions are not granted, handle it accordingly
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  });
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371; // in kilometers

  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double distance = earthRadius * c;
  return distance * 1000; // convert to meters
}

double _toRadians(double degrees) {
  return degrees * (pi / 180);
}

void dialogOnError(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
