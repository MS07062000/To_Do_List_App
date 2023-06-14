import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:to_do_list_app/HomeScreen/edit_note_view.dart';
import 'package:to_do_list_app/HomeScreen/note_content_page.dart';
import '../Database/note_model.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
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
                        return Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                            child: buildNoteCard(context, index, currentNote));
                      },
                    );
                  },
                ),
              ),
            ],
          );
  }
}

Widget buildNoteCard(BuildContext context, int noteIndex, NoteModel note) {
  return Card(
    child: ListTile(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: _getRandomColor(), width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      leading: Text(note.notetitle),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
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
          if (value == 'edit') {
            // Handle 'Edit' option
            navigateToNoteEdit(context, noteIndex, note);
          } else if (value == 'delete') {
            // Handle 'Delete' option
            deleteNote(context, noteIndex, note);
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

void navigateToNoteEdit(BuildContext context, int noteIndex, NoteModel note) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditNoteView(noteIndex: noteIndex, note: note),
    ),
  );
}

void deleteNote(BuildContext context, int noteIndex, NoteModel note) {
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
              final navigator = Navigator.of(context);
              await updateNote(
                  noteIndex: noteIndex,
                  destination: note.destination,
                  notetitle: note.notetitle,
                  isRead: note.isRead,
                  isDelete: true);
              // await Hive.box<NoteModel>('notes').delete(note.key);
              navigator.pop();
            },
          ),
        ],
      );
    },
  );
}

Color _getRandomColor() {
  final random = Random();
  final r = random.nextInt(256);
  final g = random.nextInt(256);
  final b = random.nextInt(256);

  return Color.fromARGB(255, r, g, b);
}
