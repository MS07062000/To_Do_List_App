import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  late String destination;

  @HiveField(1)
  late String notetitle;

  @HiveField(2)
  String? textnote;

  @HiveField(3)
  List<String>? checklist;

  @HiveField(4)
  bool isDelete;

  @HiveField(5)
  bool isNotified;

  NoteModel({
    required this.destination,
    required this.notetitle,
    this.textnote,
    this.checklist,
    required this.isDelete,
    required this.isNotified,
  });
}

Future<void> initializeHive() async {
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
}

Future<void> registerHiveAdapters() async {
  if (!isNoteModelRegistered()) {
    Hive.registerAdapter(NoteModelAdapter());
  }
}

bool isNoteModelRegistered() {
  return Hive.isAdapterRegistered(0); //type Id is 0 in adapter
}

Future<void> insertNote({
  required String destination,
  required String notetitle,
  String? textnote,
  List<String>? checklist,
}) async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');

  final note = NoteModel(
      destination: destination,
      notetitle: notetitle,
      textnote: textnote,
      checklist: checklist,
      isDelete: false,
      isNotified: false);

  await noteBox.add(note);
}

Future<void> updateNote({
  required dynamic noteKey,
  required String destination,
  required String notetitle,
  String? textnote,
  List<String>? checklist,
  bool? isDelete,
  bool? isNotified,
}) async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');

  final note = NoteModel(
      destination: destination,
      notetitle: notetitle,
      textnote: textnote,
      checklist: checklist,
      isDelete: isDelete ?? false,
      isNotified: isNotified ?? false);
  // print("update");
  // print(noteBox.keys.length);
  // print(noteKey);
  // print(noteBox.containsKey(noteKey));

  await noteBox.put(noteKey, note);
}

Future<List<NoteModel>> getUnreadNotes() async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');

  List<NoteModel> notesMap = [];
  for (int i = 0; i < noteBox.length; i++) {
    NoteModel? note = noteBox.getAt(i);
    if (!note!.isDelete) {
      notesMap.add(note);
    }
  }

  return notesMap;
}

Future<List<NoteModel>> getDeletedNotes() async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');

  List<NoteModel> notesMap = [];
  for (int i = 0; i < noteBox.length; i++) {
    NoteModel? note = noteBox.getAt(i);
    if (note!.isDelete) {
      notesMap.add(note);
    }
  }

  return notesMap;
}

Future<void> deleteAllPermanently(List<dynamic> noteKeys) async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');
  await noteBox.deleteAll(noteKeys);
}

Future<void> reAddAllSelectedNote(List<dynamic> noteKeys) async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');
  for (int i = 0; i < noteKeys.length; i++) {
    NoteModel? note = noteBox.get(noteKeys[i]);
    note!.isDelete = false;
    note.isNotified = false;
    noteBox.put(noteKeys[i], note);
    // print("readding");
    // print(i);
  }
}

Future<void> setDeleteOfAllSelectedNote(List<dynamic> noteKeys) async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');
  for (var noteKey in noteKeys) {
    NoteModel? note = noteBox.get(noteKey);
    note!.isDelete = true;
    await noteBox.put(noteKey, note);
  }
}

Future<List<NoteModel>> findNotesFromDestination(Position currentLocation,
    double maxDistance, bool isUsedForNotification) async {
  await Hive.close();
  await initializeHive();
  await registerHiveAdapters();
  final noteBox = await Hive.openBox<NoteModel>('notes');
  // Get the latitude and longitude of the current location
  double currentLatitude = currentLocation.latitude;
  double currentLongitude = currentLocation.longitude;

  // Filter the notes based on the distance from the current location
  List<NoteModel> filteredNotes = noteBox.values.where((note) {
    // log(note.key.toString());
    // log(note.destination);
    if (isUsedForNotification) {
      log("${note.notetitle} ${note.isDelete} ${note.isNotified}");
    }

    double noteLatitude = double.parse(note.destination.split(',')[0]);
    double noteLongitude =
        double.parse(note.destination.split(',')[1]); //note.destination;

    // Calculate the distance between the current location and note's destination
    double distanceInMeters = Geolocator.distanceBetween(
      currentLatitude,
      currentLongitude,
      noteLatitude,
      noteLongitude,
    );

    // Filter the notes within the maximum distance
    if (isUsedForNotification) {
      return distanceInMeters <= maxDistance &&
          !note.isDelete &&
          !note.isNotified;
    } else {
      return distanceInMeters <= maxDistance && !note.isDelete;
    }
  }).toList();
  return (filteredNotes);
}

Future<void> setNotified(noteKey) async {
  await initializeHive();
  await registerHiveAdapters();
  final noteBox = await Hive.openBox<NoteModel>('notes');
  NoteModel? note = noteBox.get(noteKey);
  note!.isNotified = true;
  await noteBox.put(noteKey, note);
}
