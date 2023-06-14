import 'dart:math';

import 'package:flutter/material.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/HomeScreen/note_content_page.dart';

class TrashView extends StatefulWidget {
  const TrashView({super.key});
  @override
  State<TrashView> createState() => _TrashViewState();
}

class _TrashViewState extends State<TrashView> {
  bool isLoading = true;
  late List<NoteModel> notesList;
  late ValueNotifier<List<NoteModel>> notesListNotifier;
  List<bool> selectedItems = [];
  List<int> noteIndexes = [];
  @override
  void initState() {
    super.initState();
    getDeletedData();
  }

  Future<void> getDeletedData() async {
    notesList = await getDeletedNotes();
    setState(() {
      notesListNotifier = ValueNotifier<List<NoteModel>>(notesList);
      selectedItems = List.filled(notesList.length, false);
      isLoading = false;
    });
  }

  Future<void> deleteSelectedItems() async {
    await deleteAllSelectedNote(noteIndexes);
    isLoading = true;
    await getDeletedData();
  }

  Future<void> reAddSelectedItems() async {
    await reAddAllSelectedNote(noteIndexes);
    isLoading = true;
    await getDeletedData();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // add one search bar here
              if (selectedItems.contains(true))
                Row(
                  children: [
                    const Text("Select any one?"),
                    TextButton(
                      onPressed: () {
                        setState(() async {
                          // Perform readd operation on selected items
                          await deleteSelectedItems();
                        });
                      },
                      child: const Text('Readd'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() async {
                          // Perform delete operation on selected items
                          await reAddSelectedItems();
                        });
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              Expanded(
                child: ValueListenableBuilder<List<NoteModel>>(
                  valueListenable: notesListNotifier,
                  builder: (context, notesList, _) {
                    if (notesList.isEmpty) {
                      return const Center(
                        child: Text("No Notes"),
                      );
                    }

                    return ListView.builder(
                      itemCount: notesList.length,
                      itemBuilder: (context, index) {
                        NoteModel currentNote = notesList[index];
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

  Widget buildNoteCard(BuildContext context, int noteIndex, NoteModel note) {
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _getRandomColor(), width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        // leading: Text(note.notetitle),
        leading: Checkbox(
          value: selectedItems[noteIndex],
          onChanged: (value) {
            setState(() {
              selectedItems[noteIndex] = value ?? false;
              if (selectedItems[noteIndex] == true) {
                noteIndexes.add(noteIndex);
              } else {
                if (noteIndexes.contains(noteIndex)) {
                  noteIndexes.remove(noteIndex);
                }
              }
            });
          },
        ),
        title: Text(note.notetitle),
        // trailing: PopupMenuButton(
        //   itemBuilder: (context) => [
        //     const PopupMenuItem(
        //       value: 'add',
        //       child: Text('Add Again'),
        //     ),
        //     const PopupMenuItem(
        //       value: 'delete',
        //       child: Text('Delete'),
        //     )
        //   ],
        //   onSelected: (value) {
        //     if (value == 'add') {
        //       // Handle 'Edit' option
        //       readd(context, noteIndex, note);
        //     } else if (value == 'delete') {
        //       // Handle 'Delete' option
        //       deleteNoteFromDatabase(context, note);
        //     }
        //   },
        // ),
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

  void showDialogForReaddOrDelete(BuildContext context, bool isReadd) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: isReadd
              ? const Text(
                  "Are you sure you want to readd all Selected Notes?",
                )
              : const Text(
                  "Are you sure you want to delete all Selected Notes?",
                ),
          actions: <Widget>[
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                final navigator = Navigator.of(context);
                isReadd
                    ? await reAddSelectedItems()
                    : await deleteSelectedItems();
                navigator.pop();
              },
            ),
          ],
        );
      },
    );
  }

  // void readd(BuildContext context, int noteIndex, NoteModel note) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: Text(
  //           "Do you want to add ${note.notetitle} again?",
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text("No"),
  //             onPressed: () => Navigator.of(context).pop(),
  //           ),
  //           TextButton(
  //             child: const Text("Yes"),
  //             onPressed: () async {
  //               final navigator = Navigator.of(context);
  //               await updateNote(
  //                   noteIndex: noteIndex,
  //                   destination: note.destination,
  //                   notetitle: note.notetitle,
  //                   isRead: false,
  //                   isDelete: false);
  //               navigator.pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void deleteNoteFromDatabase(BuildContext context, NoteModel note) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: Text(
  //           "Do you want to delete permanently ${note.notetitle}?",
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text("No"),
  //             onPressed: () => Navigator.of(context).pop(),
  //           ),
  //           TextButton(
  //             child: const Text("Yes"),
  //             onPressed: () async {
  //               final navigator = Navigator.of(context);
  //               await deleteNote(note.key);
  //               navigator.pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}

Color _getRandomColor() {
  final random = Random();
  final r = random.nextInt(256);
  final g = random.nextInt(256);
  final b = random.nextInt(256);

  return Color.fromARGB(255, r, g, b);
}
