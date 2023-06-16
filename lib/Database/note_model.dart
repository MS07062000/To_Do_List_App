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
  bool isRead;

  @HiveField(5)
  bool isDelete;

  NoteModel({
    required this.destination,
    required this.notetitle,
    this.textnote,
    this.checklist,
    required this.isRead,
    required this.isDelete,
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
    isRead: false,
    isDelete: false,
  );

  await noteBox.add(note);
}

Future<void> updateNote({
  required dynamic noteKey,
  required String destination,
  required String notetitle,
  String? textnote,
  List<String>? checklist,
  bool? isRead,
  bool? isDelete,
}) async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');

  final note = NoteModel(
      destination: destination,
      notetitle: notetitle,
      textnote: textnote,
      checklist: checklist,
      isRead: isRead ?? false,
      isDelete: isDelete ?? false);
  print("update");
  print(noteBox.keys.length);
  print(noteKey);
  print(noteBox.containsKey(noteKey));

  await noteBox.putAt(noteKey, note);
}

Future<List<NoteModel>> getUnreadNotes() async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');

  List<NoteModel> notesMap = [];
  for (int i = 0; i < noteBox.length; i++) {
    NoteModel? note = noteBox.getAt(i);
    if (!note!.isRead && !note.isDelete) {
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

Future<void> deleteAllPermanently() async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');
  for (int i = 0; i < noteBox.length; i++) {
    NoteModel? note = noteBox.getAt(i);
    if (note!.isDelete) {
      noteBox.deleteAt(i);
    }
  }
}

Future<void> deleteAllSelectedNote(List<dynamic> noteKey) async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');
  await noteBox.deleteAll(noteKey);
}

Future<void> reAddAllSelectedNote(List<dynamic> noteKeys) async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');
  for (int i = 0; i < noteKeys.length; i++) {
    NoteModel? note = noteBox.get(noteKeys[i]);
    print("readding");
    print(i);
    print(note!.textnote);
    if (note.textnote != null) {
      await updateNote(
          noteKey: noteKeys[i],
          destination: note.destination,
          notetitle: note.notetitle,
          textnote: note.textnote,
          isRead: false,
          isDelete: false);
    } else {
      await updateNote(
          noteKey: noteKeys[i],
          destination: note.destination,
          notetitle: note.notetitle,
          checklist: note.checklist,
          isRead: false,
          isDelete: false);
    }
  }
}

Future<void> setDeleteOfAllSelectedNote(List<dynamic> noteKeys) async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');
  for (final noteKey in noteKeys) {
    NoteModel? note = noteBox.get(noteKey);
    note!.isDelete = true;
    await noteBox.put(noteKey, note);
  }
}

Future<List<NoteModel>> findNotesFromDestination(
    Position currentLocation, double maxDistance) async {
  await initializeHive();
  await registerHiveAdapters();
  final noteBox = await Hive.openBox<NoteModel>('notes');
  // Get the latitude and longitude of the current location
  double currentLatitude = currentLocation.latitude;
  double currentLongitude = currentLocation.longitude;

  // Filter the notes based on the distance from the current location
  List<NoteModel> filteredNotes = noteBox.values.where((note) {
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
    return distanceInMeters <= maxDistance && !note.isDelete;
  }).toList();

  // Perform further operations with the filtered notes
  // For example, display the filtered notes in a list or on the map
  return (filteredNotes);
}
