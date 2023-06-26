import 'package:to_do_list_app/Database/note_model.dart';
import 'dart:math';

void insertFakeData() {
  // double latitude = 19.0171114910880906;
  // double longitude = 73.095703125;
  // List<String> destination =
  //     generateRandomGeopoints(latitude, longitude, 300, 50);
  List<String> destination = [
    "19.01709, 73.09594",
    "19.01744, 73.09632",
    "19.01768, 73.09716",
    "19.01831389861748, 73.09673799867467",
    "19.01798989469581, 73.09645795903515",
    "19.016299534163227, 73.09738225097742"
  ];
  // List<String> noteTitle = generateRandomListOfStrings(50, 50);
  List<String> noteTitle = [
    "Dance sahil",
    "Study point",
    "Kolekar academy",
    "Aishwarya",
    "SBIN atm",
    "Shiv Kamal Height"
  ];

  List<String> textNote = generateRandomListOfStrings(25, 3);
  List<List<String>> listOfLists = generateRandomStringLists(25, 10, 3);
  for (int i = 0; i < 6; i++) {
    if (i % 2 == 0) {
      insertNote(
          destination: destination[i],
          notetitle: noteTitle[i],
          textnote: textNote[i ~/ 2.0]);
    } else {
      insertNote(
          destination: destination[i],
          notetitle: noteTitle[i],
          checklist: listOfLists[i % 2]);
    }
  }
}

List<String> generateRandomGeopoints(
    double latitude, double longitude, double radiusInMeters, int count) {
  Random random = Random();
  List<String> geopoints = [];

  for (int i = 0; i < count; i++) {
    double randomRadius = radiusInMeters * sqrt(random.nextDouble());
    double randomAngle = random.nextDouble() * 2 * pi;
    double randomLatitude =
        latitude + (randomRadius * cos(randomAngle)) / 111111;
    double randomLongitude = longitude +
        (randomRadius * sin(randomAngle)) / (111111 * cos(latitude * pi / 180));
    String geopointString = '$randomLatitude, $randomLongitude';
    geopoints.add(geopointString);
  }

  return geopoints;
}

List<List<String>> generateRandomStringLists(
    int outerListLength, int innerListLength, int lengthOfEachString) {
  List<List<String>> listOfLists = [];

  for (int i = 0; i < outerListLength; i++) {
    List<String> randomStringList =
        generateRandomListOfStrings(innerListLength, lengthOfEachString);
    listOfLists.add(randomStringList);
  }

  return listOfLists;
}

List<String> generateRandomListOfStrings(int count, int lengthOfEachString) {
  List<String> strings = [];

  for (int i = 0; i < count; i++) {
    String randomString = generateRandomString(lengthOfEachString);
    strings.add(randomString);
  }

  return strings;
}

String generateRandomString(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  Random random = Random();
  String result = '';

  for (int i = 0; i < length; i++) {
    result += chars[random.nextInt(chars.length)];
  }

  return result;
}
