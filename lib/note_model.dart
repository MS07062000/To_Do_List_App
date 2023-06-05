import 'package:hive/hive.dart';

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

  NoteModel({
    required this.destination,
    required this.notetitle,
    this.textnote,
    this.checklist,
  });
}

Future<void> insertNote({
  required String destination,
  required String notetitle,
  String? textnote,
  List<String>? checklist,
}) async {
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox<NoteModel>('notes');

  final noteBox = Hive.box<NoteModel>('notes');

  final note = NoteModel(
    destination: destination,
    notetitle: notetitle,
    textnote: textnote,
    checklist: checklist,
  );

  noteBox.add(note);

  Hive.close();
}
