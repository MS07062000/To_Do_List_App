// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:to_do_list_app/note_content_page.dart';
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
  );

  await noteBox.add(note);
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
  bool isLoading = true;
  late Box<NoteModel> noteBox; // Declare a reference to the Hive box

  @override
  void initState() {
    super.initState();
    openHiveBox(); // Open the Hive box when the state is initialized
  }

  Future<void> openHiveBox() async {
    await initializeHive();
    registerHiveAdapters();
    final box = await Hive.openBox<NoteModel>('notes');
    setState(() {
      noteBox = box;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (noteBox == null) {
    //   return const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: ValueListenableBuilder<Box<NoteModel>>(
                  valueListenable: noteBox.listenable(),
                  builder: (context, box, _) {
                    if (box.values.isEmpty) {
                      return const Center(
                        child: Text("No Notes"),
                      );
                    }

                    return ListView.builder(
                      itemCount: box.length,
                      itemBuilder: (context, index) {
                        NoteModel currentNote = box.getAt(index)!;
                        return buildNoteCard(context, currentNote);
                      },
                    );
                  },
                ),
              ),
            ],
          );
  }
}

Widget buildNoteCard(BuildContext context, NoteModel note) {
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
            deleteNote(context, note);
          }
        },
      ),
      onTap: () {
        // Handle tap on note card
        navigateToNoteView(context, note);
      },
    ),
  );
}

void navigateToNoteView(BuildContext context, NoteModel note) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NoteContentPage(note: note),
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
