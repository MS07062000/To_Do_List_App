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
  late ValueNotifier<Map<dynamic, NoteModel>> notesMapNotifier;
  List<bool> selectedItems = [];
  List<dynamic> notesKeys = [];
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
    notesMapNotifier =
        ValueNotifier<Map<dynamic, NoteModel>>(await getUnreadNotes());
    selectedItems = List.filled(notesMapNotifier.value.length, false);
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
              Expanded(
                child: ValueListenableBuilder<Map<dynamic, NoteModel>>(
                  valueListenable: notesMapNotifier,
                  builder: (context, notesMap, _) {
                    if (notesMap.isEmpty) {
                      return const Center(
                        child: Text("No Notes"),
                      );
                    }

                    return Consumer<BottomNavBarProvider>(
                      builder: (context, bottomNavBarProvider, child) {
                        return ListView.builder(
                          itemCount: notesMap.length,
                          itemBuilder: (context, index) {
                            dynamic key = notesMap.keys.elementAt(index);
                            NoteModel currentNote = notesMap[key]!;
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                              child: buildNoteCard(
                                  context, index, key, currentNote),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
  }

  Widget buildNoteCard(
      BuildContext context, int noteIndex, dynamic noteKey, NoteModel note) {
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
                notesKeys.add(noteKey);
                Provider.of<BottomNavBarProvider>(context, listen: false)
                    .setNotesKeys(notesKeys);
              } else {
                if (notesKeys.contains(noteKey)) {
                  notesKeys.remove(noteKey);
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
            navigateToNoteEdit(context, noteKey, note);
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

  void navigateToNoteEdit(
      BuildContext context, dynamic noteKey, NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        maintainState: false,
        builder: (context) => EditNoteView(noteKey: noteKey, note: note),
      ),
    ).then((value) {
      setState(() {
        isLoading = true;
      });
      getNotes();
    });
  }

  void deleteNote(BuildContext context, int noteKey, NoteModel note) {
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
              onPressed: () {
                if (note.textnote != null) {
                  updateNote(
                      noteKey: noteKey,
                      destination: note.destination,
                      notetitle: note.notetitle,
                      textnote: note.textnote,
                      isRead: true,
                      isDelete: true);
                } else {
                  updateNote(
                      noteKey: noteKey,
                      destination: note.destination,
                      notetitle: note.notetitle,
                      checklist: note.checklist,
                      isRead: true,
                      isDelete: true);
                }
                Navigator.of(context).pop();
                setState(() {
                  isLoading = true;
                });
                getNotes();
                // await Hive.box<NoteModel>('notes').delete(note.key);
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
}
