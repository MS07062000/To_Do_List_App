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
  late List<NoteModel> notesMap;
  late ValueNotifier<List<NoteModel>> notesMapNotifier;
  List<bool> selectedItems = [];
  List<dynamic> notesKeys = [];
  @override
  void initState() {
    super.initState();
    getDeletedData();
  }

  Future<void> getDeletedData() async {
    notesMap = await getDeletedNotes();
    setState(() {
      notesMapNotifier = ValueNotifier<List<NoteModel>>(notesMap);
      selectedItems = List.filled(notesMap.length, false);
      isLoading = false;
    });
  }

  Future<void> deleteSelectedItems() async {
    await deleteAllSelectedNote(notesKeys);
    isLoading = true;
    await getDeletedData();
  }

  Future<void> reAddSelectedItems() async {
    await reAddAllSelectedNote(notesKeys);
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
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Select any one?"),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[900],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            // Perform readd operation on selected items
                            showDialogForReaddOrDelete(context, true);
                          },
                          child: const Text('Readd'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.red, // background (button) color
                            foregroundColor:
                                Colors.white, // foreground (text) color
                          ),
                          onPressed: () {
                            // Perform delete operation on selected items
                            showDialogForReaddOrDelete(context, false);
                          },
                          child: const Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ValueListenableBuilder<List<NoteModel>>(
                  valueListenable: notesMapNotifier,
                  builder: (context, notesMap, _) {
                    if (notesMap.isEmpty) {
                      return const Center(
                        child: Text("No Notes"),
                      );
                    }

                    return ListView.builder(
                      itemCount: notesMap.length,
                      itemBuilder: (context, index) {
                        NoteModel currentNote = notesMap[index];
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
                notesKeys.add(note.key);
              } else {
                if (notesKeys.contains(note.key)) {
                  notesKeys.remove(note.key);
                }
              }
            });
          },
        ),
        title: Text(note.notetitle),
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
