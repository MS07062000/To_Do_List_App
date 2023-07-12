import 'dart:async';
// import 'dart:developer';
import 'package:location/location.dart';
import 'package:to_do_list_app/Helper/NoteCard/note_card.dart';
import 'package:to_do_list_app/Helper/SearchBar/search_bar.dart';
import 'package:to_do_list_app/Helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list_app/HomeScreen/edit_note_view.dart';
// import 'package:to_do_list_app/HomeScreen/note_content_page.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:tuple/tuple.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => NoteViewState();
}

class NoteViewState extends State<NoteView> {
  bool isLoading = true;
  bool isLocationServicesAvailable = false;
  List<bool> selectedItems = [];
  List<dynamic> notesKeys = [];
  TextEditingController searchController = TextEditingController();
  List<NoteModel> fetchedNotes = [];
  List<NoteModel> displayedNotes = [];
  List<NoteModel> filteredNotes = [];

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getNotes() async {
    await getUnreadNotes().then((value) {
      Tuple2<List<NoteModel>, bool> unreadNotesResult = value;
      if (unreadNotesResult.item2) {
        setState(() {
          fetchedNotes = unreadNotesResult.item1;
          displayedNotes = fetchedNotes;
          selectedItems = List.filled(displayedNotes.length, false);
          isLoading = false;
        });
      } else {
        dialogOnError(context, "Error in getting Notes");
      }
    });
  }

  void searchHandler(String input) {
    setState(() {
      filteredNotes = fetchedNotes
          .where((note) =>
              note.notetitle.toLowerCase().contains(input.toLowerCase()))
          .toList();
      displayedNotes = filteredNotes;
    });
  }

  void handleSelectAllChange(bool selectAll) {
    setState(() {
      selectedItems = List.filled(displayedNotes.length, selectAll);
      if (selectAll) {
        notesKeys = displayedNotes.map((note) => note.key).toList();
      } else {
        notesKeys = [];
      }
    });
  }

  void sortHandler(String sortBy) {
    if (sortBy == 'location') {
      sortByLocation();
    }

    if (sortBy == 'noteTitle') {
      sortByNoteTitle();
    }
  }

  void sortByNoteTitle() {
    setState(() {
      displayedNotes.sort((a, b) =>
          a.notetitle.toLowerCase().compareTo(b.notetitle.toLowerCase()));
    });
  }

  void sortByLocation() {
    locationPermissionAndServicesEnabled().then((value) {
      if (value) {
        Location().getLocation().then((location) {
          setState(() {
            displayedNotes.sort((a, b) {
              final double distanceToA = calculateDistance(
                  location.latitude!,
                  location.longitude!,
                  double.parse(a.destinationCoordinates.split(',')[0]),
                  double.parse(a.destinationCoordinates.split(',')[1]));

              final double distanceToB = calculateDistance(
                  location.latitude!,
                  location.longitude!,
                  double.parse(b.destinationCoordinates.split(',')[0]),
                  double.parse(b.destinationCoordinates.split(',')[1]));
              // log(distanceToA.toString());
              // log(distanceToB.toString());
              return distanceToA.compareTo(distanceToB);
            });
          });
        });
      } else {
        locationPermissionAndServicesEnabled();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Location List"),
          automaticallyImplyLeading: false,
          actions: [
            Row(
              children: [
                if (displayedNotes.isNotEmpty) ...[
                  PopupMenuButton(
                    icon: const Icon(Icons.sort),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                      const PopupMenuItem(
                        value: 'noteTitle',
                        child: Text('Sort by Note Title'),
                      ),
                      const PopupMenuItem(
                        value: 'location',
                        child: Text('Sort by Location'),
                      )
                    ],
                    onSelected: (selectedOption) {
                      sortHandler(selectedOption);
                    },
                  ),
                  const SizedBox(width: 4),
                  if (notesKeys.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        deleteSelectedNotes(context, notesKeys);
                      },
                    ),
                ],
              ],
            )
          ]),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (fetchedNotes.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                          child: searchBar(searchController, searchHandler)),
                    ],
                  ),
                  if (selectedItems.contains(true))
                    Row(
                      children: [
                        Expanded(child: selectAllContainer()),
                      ],
                    ),
                ],
                noteListContainer()
              ],
            ),
    );
  }

  Widget selectAllContainer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text('Select All'),
        value: selectedItems.every((isSelected) => isSelected),
        onChanged: (value) {
          handleSelectAllChange(value!);
        },
      ),
    );
  }

  Widget noteListContainer() {
    if (searchController.text.isNotEmpty && filteredNotes.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No notes found as per the input entered by you.',
          ),
        ),
      );
    } else if (displayedNotes.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text("No Notes"),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: displayedNotes.length,
          itemBuilder: (context, index) {
            NoteModel currentNote = displayedNotes[index];
            return Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8.0, top: 0, bottom: 0),
              child: buildNoteCard(context, handleCardCheckBox,
                  navigateToNoteEdit, selectedItems, index, currentNote),
            );
          },
        ),
      );
    }
  }

  void handleCardCheckBox(
      bool? checkBoxSelected, int noteIndex, NoteModel note) {
    setState(() {
      selectedItems[noteIndex] = checkBoxSelected ?? false;
      if (selectedItems[noteIndex]) {
        if (!notesKeys.contains(note.key)) {
          notesKeys.add(note.key);
        }
      } else {
        if (notesKeys.contains(note.key)) {
          notesKeys.remove(note.key);
        }
      }
    });
  }

  void navigateToNoteEdit(BuildContext context, NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        maintainState: true,
        builder: (context) => EditNoteView(noteKey: note.key, note: note),
      ),
    ).then((value) {
      setState(() {
        isLoading = true;
      });
      getNotes();
    });
  }

  void deleteSelectedNotes(BuildContext context, List<dynamic> noteKeys) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
            "Do you want to delete all selected notes?",
          ),
          actions: <Widget>[
            TextButton(
                child: const Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                setDeleteOfAllSelectedNote(noteKeys).then((value) {
                  notesKeys = [];
                  Navigator.of(context).pop();
                  getNotes();

                  if (!value) {
                    dialogOnError(context, "Error in Deleting Notes");
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }
}
