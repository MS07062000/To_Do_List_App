import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/HomeScreen/note_content_page.dart';
import 'package:to_do_list_app/main.dart';

class TrashView extends StatefulWidget {
  const TrashView({super.key});
  @override
  State<TrashView> createState() => _TrashViewState();
}

class _TrashViewState extends State<TrashView> {
  bool isLoading = true;
  // late List<NoteModel> notes;
  late ValueNotifier<List<NoteModel>> notesNotifier;
  List<bool> selectedItems = [];
  List<dynamic> notesKeys = [];
  TextEditingController searchController = TextEditingController();
  List<NoteModel> filteredNotes = [];
  @override
  void initState() {
    super.initState();
    getDeletedData();
    Provider.of<BottomNavBarProvider>(context, listen: false)
        .refreshNotifier
        .addListener(_refreshNotes);
  }

  @override
  void dispose() {
    Provider.of<BottomNavBarProvider>(context, listen: false)
        .refreshNotifier
        .addListener(_refreshNotes);
    super.dispose();
  }

  void _refreshNotes() {
    if (!Provider.of<BottomNavBarProvider>(context, listen: false)
        .refreshNotifier
        .value) {
      return;
    }
    if (mounted) {
      setState(() {
        isLoading = true;
      });
      getDeletedData();
    }

    Provider.of<BottomNavBarProvider>(context, listen: false)
        .refreshNotifier
        .value = false;
  }

  Future<void> getDeletedData() async {
    notesNotifier = ValueNotifier<List<NoteModel>>(await getDeletedNotes());
    selectedItems = List.filled(notesNotifier.value.length, false);
    setState(() {
      isLoading = false;
      // print(isLoading);
    });
  }

  Future<void> deleteSelectedItems() async {
    await deleteAllPermanently(notesKeys);

    Provider.of<BottomNavBarProvider>(context, listen: false)
        .refreshNotifier
        .value = true;
  }

  void reAddSelectedItems() {
    reAddAllSelectedNote(
            Provider.of<BottomNavBarProvider>(context, listen: false).noteKeys)
        .then((value) {
      Provider.of<BottomNavBarProvider>(context, listen: false)
          .refreshNotifier
          .value = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              if (notesNotifier.value.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {
                              filteredNotes = notesNotifier.value
                                  .where((note) => note.notetitle
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Search Notes',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (selectedItems.contains(true)) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          color: Colors.green[900],
                          onPressed: () {
                            showDialogForReaddOrDelete(context, true);
                          },
                          icon: const Icon(Icons.replay)),
                      const Spacer(),
                      const Text("Select any one?"),
                      const Spacer(),
                      IconButton(
                          color: Colors.red[900],
                          onPressed: () {
                            showDialogForReaddOrDelete(context, false);
                          },
                          icon: const Icon(Icons.delete_forever)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('Select All'),
                          value:
                              selectedItems.every((isSelected) => isSelected),
                          onChanged: (value) {
                            setState(
                              () {
                                selectedItems = List.filled(
                                    notesNotifier.value.length, value ?? false);
                                if (value!) {
                                  for (var note in notesNotifier.value) {
                                    if (!notesKeys.contains(note.key)) {
                                      notesKeys.add(note.key);
                                    }
                                  }
                                } else {
                                  for (var note in notesNotifier.value) {
                                    if (!notesKeys.contains(note.key)) {
                                      notesKeys.remove(note.key);
                                    }
                                  }
                                }
                                Provider.of<BottomNavBarProvider>(context,
                                        listen: false)
                                    .setNotesKeys(notesKeys);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Expanded(
                child: ValueListenableBuilder<List<NoteModel>>(
                  valueListenable: notesNotifier,
                  builder: (context, notes, _) {
                    List<NoteModel> displayedNotes =
                        searchController.text.isEmpty ? notes : filteredNotes;

                    if (notes.isEmpty) {
                      return const Center(
                        child: Text("No Notes"),
                      );
                    }

                    if (displayedNotes.isEmpty) {
                      return const Center(
                        child: Text(
                          'No notes found as per the input entered by you.',
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: displayedNotes.length,
                      itemBuilder: (context, index) {
                        NoteModel currentNote = displayedNotes[index];
                        return Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 0, bottom: 0),
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
        leading: Checkbox(
          value: selectedItems[noteIndex],
          onChanged: (value) {
            setState(() {
              selectedItems[noteIndex] = value ?? false;
              if (selectedItems[noteIndex]) {
                if (!notesKeys.contains(note.key)) {
                  notesKeys.add(note.key);
                }
              } else {
                if (notesKeys.contains(note.key)) {
                  notesKeys.remove(note.key);
                }
              }
              Provider.of<BottomNavBarProvider>(context, listen: false)
                  .setNotesKeys(notesKeys);
            });
          },
        ),
        title: Text(note.notetitle),
        onTap: () {
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
                  "Are you sure you want to readd all Selected Notes ?",
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
              onPressed: () {
                isReadd ? reAddSelectedItems() : deleteSelectedItems();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

Color _getRandomColor() {
  final random = Random();
  final r = random.nextInt(256);
  final g = random.nextInt(256);
  final b = random.nextInt(256);

  return Color.fromARGB(255, r, g, b);
}

// Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green[900],
//                             foregroundColor: Colors.white,
//                           ),
//                           onPressed: () {
//                             // Perform readd operation on selected items
//                             showDialogForReaddOrDelete(context, true);
//                           },
//                           child: const Text('Readd'),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 Colors.red, // background (button) color
//                             foregroundColor:
//                                 Colors.white, // foreground (text) color
//                           ),
//                           onPressed: () {
//                             // Perform delete operation on selected items
//                             showDialogForReaddOrDelete(context, false);
//                           },
//                           child: const Text('Delete'),
//                         ),
//                       ),












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