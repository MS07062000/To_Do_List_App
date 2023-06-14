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
  required int noteIndex,
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

  await noteBox.putAt(noteIndex, note);
}

Future<List<NoteModel>> getUnreadNotes() async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');

  List<NoteModel> notes = [];
  for (int i = 0; i < noteBox.length; i++) {
    final note = noteBox.getAt(i) as NoteModel;
    if (!note.isRead && !note.isDelete) {
      notes.add(note);
    }
  }

  return notes;
}

Future<List<NoteModel>> getDeletedNotes() async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');

  List<NoteModel> notes = [];
  for (int i = 0; i < noteBox.length; i++) {
    final note = noteBox.getAt(i) as NoteModel;
    if (note.isDelete) {
      notes.add(note);
    }
  }

  return notes;
}

Future<List<NoteModel>> deleteAllPermanently() async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');
  List<NoteModel> notes = [];
  for (int i = 0; i < noteBox.length; i++) {
    final note = noteBox.getAt(i) as NoteModel;
    if (note.isDelete) {
      notes.add(note);
    }
  }

  return notes;
}

Future<void> deleteAllSelectedNote(List<int> noteIndexes) async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');
  await noteBox.deleteAll(noteIndexes);
}

Future<void> reAddAllSelectedNote(List<int> noteIndexes) async {
  await initializeHive();
  await registerHiveAdapters();

  final noteBox = await Hive.openBox<NoteModel>('notes');
  for (int noteIndex in noteIndexes) {
    NoteModel? note = noteBox.getAt(noteIndex);
    if (note!.textnote != null) {
      await updateNote(
          noteIndex: noteIndex,
          destination: note.destination,
          notetitle: note.destination,
          textnote: note.textnote,
          isRead: false,
          isDelete: false);
    } else {
      await updateNote(
          noteIndex: noteIndex,
          destination: note.destination,
          notetitle: note.destination,
          checklist: note.checklist,
          isRead: false,
          isDelete: false);
    }
  }
}
