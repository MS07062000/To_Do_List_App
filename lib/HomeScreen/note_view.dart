import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/HomeScreen/edit_note_view.dart';
import 'package:to_do_list_app/HomeScreen/note_content_page.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/main.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => NoteViewState();
}

class NoteViewState extends State<NoteView> {
  bool isLoading = true;
  late ValueNotifier<List<NoteModel>> notesNotifier;
  List<bool> selectedItems = [];
  List<dynamic> notesKeys = [];
  TextEditingController searchController = TextEditingController();

  List<NoteModel> filteredNotes = [];
  @override
  void initState() {
    super.initState();
    getNotes();
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
      getNotes();
    }
    Provider.of<BottomNavBarProvider>(context, listen: false)
        .refreshNotifier
        .value = false;
  }

  Future<void> getNotes() async {
    notesNotifier = ValueNotifier<List<NoteModel>>(await getUnreadNotes());
    selectedItems = List.filled(notesNotifier.value.length, false);
    setState(() {
      isLoading = false;
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
                if (selectedItems.contains(true))
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                          child: CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text('Select All'),
                            value:
                                selectedItems.every((isSelected) => isSelected),
                            onChanged: (value) {
                              setState(() {
                                selectedItems = List.filled(
                                    notesNotifier.value.length, value ?? false);
                                // selectAll = value ?? false;
                                // if (selectAll) {
                                //   selectedItems = List.filled(
                                //       notesNotifier.value.length, value ?? false);
                                // } else {
                                //   selectedItems = List.filled(
                                //       notesNotifier.value.length, false);
                                // }
                                // notesNotifier.value.forEach((note) {
                                // if (!notesKeys.contains(note.key)) {
                                //   notesKeys.add(note.key);
                                // }
                                //   });
                                // } else {
                                //    notesKeys.clear();
                                // }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
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
                              left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                          child: buildNoteCard(context, index, currentNote),
                        );
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
              if (selectedItems[noteIndex] == true) {
                notesKeys.add(note.key);
                Provider.of<BottomNavBarProvider>(context, listen: false)
                    .setNotesKeys(notesKeys);
              } else {
                if (notesKeys.contains(note.key)) {
                  notesKeys.remove(note.key);
                  Provider.of<BottomNavBarProvider>(context, listen: false)
                      .setNotesKeys(notesKeys);
                }
              }
            });
          },
        ),
        title: Text(note.notetitle),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            navigateToNoteEdit(context, note);
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
        maintainState: false,
        builder: (context) => NoteContentPage(note: note),
      ),
    );
  }

  void navigateToNoteEdit(BuildContext context, NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        maintainState: false,
        builder: (context) => EditNoteView(noteKey: note.key, note: note),
      ),
    ).then((value) {
      setState(() {
        isLoading = true;
      });
      getNotes();
    });
  }

  Color _getRandomColor() {
    final random = Random();
    final r = random.nextInt(256);
    final g = random.nextInt(256);
    final b = random.nextInt(256);

    return Color.fromARGB(255, r, g, b);
  }
}



// void deleteNote(BuildContext context, int noteKey, NoteModel note) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: Text(
  //           "Do you want to delete ${note.notetitle}?",
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text("No"),
  //             onPressed: () => Navigator.of(context).pop(),
  //           ),
  //           TextButton(
  //             child: const Text("Yes"),
  //             onPressed: () {
  //               if (note.textnote != null) {
  //                 updateNote(
  //                     noteKey: noteKey,
  //                     destination: note.destination,
  //                     notetitle: note.notetitle,
  //                     textnote: note.textnote,
  //                     isRead: true,
  //                     isDelete: true);
  //               } else {
  //                 updateNote(
  //                     noteKey: noteKey,
  //                     destination: note.destination,
  //                     notetitle: note.notetitle,
  //                     checklist: note.checklist,
  //                     isRead: true,
  //                     isDelete: true);
  //               }
  //               Navigator.of(context).pop();
  //               setState(() {
  //                 isLoading = true;
  //               });
  //               getNotes();
  //               // await Hive.box<NoteModel>('notes').delete(note.key);
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }