import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  void searchHandler(String input) {
    setState(() {
      filteredNotes = notesNotifier.value
          .where((note) =>
              note.notetitle.toLowerCase().contains(input.toLowerCase()))
          .toList();
    });
  }

  void handleSelectAllChange(bool? selectAll) {
    setState(() {
      selectedItems =
          List.filled(notesNotifier.value.length, selectAll ?? false);
      if (selectAll!) {
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
      Provider.of<BottomNavBarProvider>(context, listen: false)
          .setNotesKeys(notesKeys);
    });
  }

  void sortHandler(String sortBy, List<NoteModel> notes) {
    if (sortBy == 'location') {
      sortByLocation(notes);
    }

    if (sortBy == 'noteTitle') {
      sortByNoteTitle(notes);
    }
  }

  void sortByNoteTitle(List<NoteModel> notes) {
    notes.sort((a, b) => a.notetitle.compareTo(b.notetitle));
  }

  void sortByLocation(List<NoteModel> notes) {
    if (Provider.of<BottomNavBarProvider>(context, listen: false)
        .isLocationServicesAvailable
        .value) {
      notes.sort((a, b) {
        Geolocator.getCurrentPosition(timeLimit: const Duration(seconds: 10))
            .then((location) {
          final double distanceToA = Geolocator.distanceBetween(
              location.latitude,
              location.longitude,
              double.parse(a.destination.split(',')[0]),
              double.parse(a.destination.split(',')[1]));

          final double distanceToB = Geolocator.distanceBetween(
              location.latitude,
              location.longitude,
              double.parse(a.destination.split(',')[0]),
              double.parse(a.destination.split(',')[1]));
          return distanceToA.compareTo(distanceToB);
        });
        return 0;
      });
    }
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
                              searchHandler(value);
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
                              handleSelectAllChange(value);
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
                      Provider.of<BottomNavBarProvider>(context, listen: false)
                          .isNotesAvailable
                          .value = false;
                      return const Center(
                        child: Text("No Notes"),
                      );
                    }

                    if (displayedNotes.isEmpty) {
                      Provider.of<BottomNavBarProvider>(context, listen: false)
                          .isNotesAvailable
                          .value = false;

                      return const Center(
                        child: Text(
                          'No notes found as per the input entered by you.',
                        ),
                      );
                    }

                    Provider.of<BottomNavBarProvider>(context, listen: false)
                        .isNotesAvailable
                        .value = true;

                    if (Provider.of<BottomNavBarProvider>(context,
                                listen: false)
                            .sortBy
                            .value !=
                        '') {
                      sortHandler(
                          Provider.of<BottomNavBarProvider>(context,
                                  listen: false)
                              .sortBy
                              .value,
                          displayedNotes);
                    }

                    return ListView.builder(
                      itemCount: displayedNotes.length,
                      itemBuilder: (context, index) {
                        NoteModel currentNote = displayedNotes[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, top: 0, bottom: 0),
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
            handleCardCheckBox(value, noteIndex, note);
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

  void handleCardCheckBox(
      bool? checkBoxSelected, int noteIndex, NoteModel note) {
    setState(() {
      selectedItems[noteIndex] = checkBoxSelected ?? false;
      if (selectedItems[noteIndex]) {
        if (!notesKeys.contains(note.key)) {
          notesKeys.add(note.key);
        }
        // print(noteIndex);
        // print("card add");
        // print(notesKeys);
      } else {
        if (notesKeys.contains(note.key)) {
          notesKeys.remove(note.key);
          // print(noteIndex);
          // print("card remove");
          // print(notesKeys);
        }
      }
      Provider.of<BottomNavBarProvider>(context, listen: false)
          .setNotesKeys(notesKeys);
    });
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
