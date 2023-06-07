import 'dart:js';
import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'note_view.dart';
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
  // await Hive.openBox<NoteModel>('notes');

  final noteBox = await Hive.openBox<NoteModel>('notes');

  final note = NoteModel(
    destination: destination,
    notetitle: notetitle,
    textnote: textnote,
    checklist: checklist,
  );

  noteBox.add(note);

  Hive.close();
}

// Future<void> deleteNote({

// }) async {
//   final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
//   Hive.init(appDocumentDir.path);
//   // await Hive.openBox<NoteModel>('notes');

//   final noteBox = await Hive.openBox<NoteModel>('notes');

//   Hive.close();
// }

class NoteView extends StatefulWidget {
  @override
  _NoteViewState createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  @override
  Widget build(BuildContext context) {
    return (ValueListenableBuilder(
        valueListenable: Hive.box<NoteModel>('notes').listenable(),
        builder: (context, Box<NoteModel> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text("No Notes"),
            );
          }
          return ListView.builder(
              itemCount: box.values.length,
              itemBuilder: (context, index) {
                NoteModel? currentNote = box.getAt(index);
                buildNoteCard(currentNote!);
              });
        }));
  }
}

Widget buildNoteCard(NoteModel note) {
  return Card(
    child: ListTile(
      leading: Text(note.notetitle),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'start',
            child: Text('Start'),
          ),
          const PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          )
        ],
        onSelected: (value) {
          if (value == 'start') {
            // Handle 'Start' option
          } else if (value == 'edit') {
            // Handle 'Edit' option
          } else if (value == 'delete') {
            // Handle 'Delete' option
            deleteNote(context as BuildContext, note);
          }
        },
      ),
      onTap: () {
        // Handle tap on note card
        navigateToNoteView(note);
      },
    ),
  );
}

void navigateToNoteView(NoteModel note) {
  Navigator.push(
    context as BuildContext,
    MaterialPageRoute(
      builder: (context) => NoteViewPage(note: note),
    ),
  );
}

void deleteNote(BuildContext context, NoteModel note) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text(
          "Do you want to delete ${note.notetitle}?",
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Yes"),
            onPressed: () async {
              await Hive.box<NoteModel>('notes').delete(note.key);
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
