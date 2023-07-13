// import 'dart:developer';
import 'package:hive_flutter/adapters.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:to_do_list_app/Helper/helper.dart';
import 'package:tuple/tuple.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  late String destination;

  @HiveField(1)
  late String destinationCoordinates;

  @HiveField(2)
  late String notetitle;

  @HiveField(3, defaultValue: '')
  String? textnote;

  @HiveField(4, defaultValue: [])
  List<String>? checklist;

  @HiveField(5)
  bool isDelete;

  @HiveField(6)
  bool isNotified;

  NoteModel({
    required this.destination,
    required this.destinationCoordinates,
    required this.notetitle,
    this.textnote,
    this.checklist,
    required this.isDelete,
    required this.isNotified,
  });

  factory NoteModel.fromJson(Map<String, dynamic> note) {
    if (note['textnote'] != '') {
      return NoteModel(
        destination: note['destination'],
        destinationCoordinates: note['destinationCoordinates'],
        notetitle: note['notetitle'],
        textnote: note['textnote'],
        isDelete: note['isDelete'],
        isNotified: note['isNotified'],
      );
    }

    return NoteModel(
      destination: note['destination'],
      destinationCoordinates: note['destinationCoordinates'],
      notetitle: note['notetitle'],
      checklist: List<String>.from(note['checklist']),
      isDelete: note['isDelete'],
      isNotified: note['isNotified'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> note = {};
    note['destination'] = destination;
    note['destinationCoordinates'] = destinationCoordinates;
    note['notetitle'] = notetitle;
    if (textnote != null) {
      note['textnote'] = textnote;
    }
    if (checklist != null) {
      note['checklist'] = checklist;
    }
    note['isDelete'] = isDelete;
    note['isNotified'] = isNotified;
    return note;
  }
}

Future<void> initializeHive() async {
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
}

void registerHiveAdapters() {
  if (!isNoteModelRegistered()) {
    Hive.registerAdapter(NoteModelAdapter());
  }
}

bool isNoteModelRegistered() {
  return Hive.isAdapterRegistered(0); //type Id is 0 in adapter
}

Future<bool> insertNote({
  required String destination,
  required String destinationCoordinates,
  required String notetitle,
  String? textnote,
  List<String>? checklist,
}) async {
  try {
    await initializeHive();
    registerHiveAdapters();

    final noteBox = await Hive.openBox<NoteModel>('notes');

    final note = NoteModel(
        destination: destination,
        destinationCoordinates: destinationCoordinates,
        notetitle: notetitle,
        textnote: textnote,
        checklist: checklist,
        isDelete: false,
        isNotified: false);

    await noteBox.add(note);
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> updateNote({
  required dynamic noteKey,
  required String destination,
  required String destinationCoordinates,
  required String notetitle,
  String? textnote,
  List<String>? checklist,
  required bool isDelete,
  required bool isNotified,
}) async {
  try {
    await initializeHive();
    registerHiveAdapters();
    final noteBox = await Hive.openBox<NoteModel>('notes');
    final note = NoteModel(
        destination: destination,
        destinationCoordinates: destinationCoordinates,
        notetitle: notetitle,
        textnote: textnote,
        checklist: checklist,
        isDelete: isDelete,
        isNotified: isNotified);
    // log("update");
    // log('${noteBox.keys.length}');
    // log('${noteKey}');
    // log('${noteBox.containsKey(noteKey)}');
    await noteBox.put(noteKey, note);
    return true;
  } catch (_) {
    return false;
  }
}

Future<Tuple2<List<NoteModel>, bool>> getUnreadNotes() async {
  try {
    await initializeHive();
    registerHiveAdapters();
    final noteBox = await Hive.openBox<NoteModel>('notes');

    List<NoteModel> notesMap = [];
    for (int i = 0; i < noteBox.length; i++) {
      NoteModel? note = noteBox.getAt(i);
      if (!note!.isDelete) {
        notesMap.add(note);
      }
    }
    return Tuple2(notesMap, true);
  } catch (_) {
    return const Tuple2([], false);
  }
}

Future<Tuple2<List<NoteModel>, bool>> getDeletedNotes() async {
  try {
    await initializeHive();
    registerHiveAdapters();
    final noteBox = await Hive.openBox<NoteModel>('notes');

    List<NoteModel> notesMap = [];
    for (int i = 0; i < noteBox.length; i++) {
      NoteModel? note = noteBox.getAt(i);
      if (note!.isDelete) {
        notesMap.add(note);
      }
    }
    return Tuple2(notesMap, true);
  } catch (_) {
    return const Tuple2([], false);
  }
}

Future<bool> deleteAllPermanently(List<dynamic> noteKeys) async {
  try {
    await initializeHive();
    registerHiveAdapters();
    final noteBox = await Hive.openBox<NoteModel>('notes');
    await noteBox.deleteAll(noteKeys);
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> reAddAllSelectedNote(List<dynamic> noteKeys) async {
  try {
    await initializeHive();
    registerHiveAdapters();

    final noteBox = await Hive.openBox<NoteModel>('notes');
    for (int i = 0; i < noteKeys.length; i++) {
      NoteModel? note = noteBox.get(noteKeys[i]);
      note!.isDelete = false;
      note.isNotified = false;
      await noteBox.put(noteKeys[i], note);
      // log("readding");
      // log(i.toString());
    }
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> setDeleteOfAllSelectedNote(List<dynamic> noteKeys) async {
  try {
    await initializeHive();
    registerHiveAdapters();

    final noteBox = await Hive.openBox<NoteModel>('notes');
    for (var noteKey in noteKeys) {
      NoteModel? note = noteBox.get(noteKey);
      note!.isDelete = true;
      await noteBox.put(noteKey, note);
    }
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> setNotified(noteKey) async {
  try {
    await initializeHive();
    registerHiveAdapters();

    final noteBox = await Hive.openBox<NoteModel>('notes');
    NoteModel? note = noteBox.get(noteKey);
    note!.isNotified = true;
    await noteBox.put(noteKey, note);
    return true;
  } catch (_) {
    return false;
  }
}

Future<Tuple2<List<NoteModel>, bool>> findNotesFromDestination(
    LocationData currentLocation,
    double maxDistance,
    bool isUsedForNotification) async {
  try {
    await Hive.close();
    await initializeHive();
    registerHiveAdapters();

    final noteBox = await Hive.openBox<NoteModel>('notes');
    // Get the latitude and longitude of the current location
    double? currentLatitude = currentLocation.latitude;
    double? currentLongitude = currentLocation.longitude;

    // Filter the notes based on the distance from the current location
    List<NoteModel> filteredNotes = noteBox.values.where((note) {
      // log('${note.key}');
      // log('${note.destination}');
      // if (isUsedForNotification) {
      //   log("${note.notetitle} ${note.isDelete} ${note.isNotified} ${note.destinationCoordinates}");
      // }

      double noteLatitude =
          double.parse(note.destinationCoordinates.split(',')[0]);
      double noteLongitude = double.parse(
          note.destinationCoordinates.split(',')[1]); //note.destination;

      // Calculate the distance between the current location and note's destination
      double distanceInMeters = calculateDistance(
        currentLatitude!,
        currentLongitude!,
        noteLatitude,
        noteLongitude,
      );

      //log(distanceInMeters.toString());
      // Filter the notes within the maximum distance
      if (isUsedForNotification) {
        return distanceInMeters <= maxDistance &&
            !note.isDelete &&
            !note.isNotified;
      } else {
        return distanceInMeters <= maxDistance && !note.isDelete;
      }
    }).toList();
    return Tuple2(filteredNotes, true);
  } catch (_) {
    return const Tuple2([], false);
  }
}
