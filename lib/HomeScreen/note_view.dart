import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:to_do_list_app/HomeScreen/note_content_page.dart';
import '../Database/note_model.dart';

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

Color _getRandomColor() {
  final random = Random();
  final r = random.nextInt(256);
  final g = random.nextInt(256);
  final b = random.nextInt(256);

  return Color.fromARGB(255, r, g, b);
}
