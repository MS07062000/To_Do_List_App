import 'package:flutter/material.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/Helper/NoteCard/note_card.dart';
import 'package:to_do_list_app/Helper/SearchBar/search_bar.dart';
import 'package:to_do_list_app/Helper/helper.dart';
import 'package:tuple/tuple.dart';

class TrashView extends StatefulWidget {
  const TrashView({super.key});
  @override
  State<TrashView> createState() => _TrashViewState();
}

class _TrashViewState extends State<TrashView> {
  bool isLoading = true;
  List<bool> selectedItems = [];
  List<dynamic> notesKeys = [];
  TextEditingController searchController = TextEditingController();
  List<NoteModel> displayedNotes = [];
  List<NoteModel> fetchedNotes = [];
  List<NoteModel> filteredNotes = [];

  @override
  void initState() {
    super.initState();
    getTrashNotes();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> getTrashNotes() async {
    await getDeletedNotes().then((value) {
      Tuple2<List<NoteModel>, bool> deletedNotesResult = value;
      if (deletedNotesResult.item2) {
        setState(() {
          fetchedNotes = deletedNotesResult.item1;
          displayedNotes = fetchedNotes;
          selectedItems = List.filled(displayedNotes.length, false);
          isLoading = false;
        });
      } else {
        dialogOnError(context, "Error in getting deleted Notes");
      }
    });
  }

  void sortByNoteTitle() {
    setState(() {
      displayedNotes.sort((a, b) =>
          a.notetitle.toLowerCase().compareTo(b.notetitle.toLowerCase()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location List"),
        automaticallyImplyLeading: false,
        actions: [
          if (displayedNotes.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.sort_by_alpha),
              onPressed: () {
                sortByNoteTitle();
              },
            ),
            const SizedBox(width: 8),
          ]
        ],
      ),
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
                ],
                if (selectedItems.contains(true)) ...[
                  readdOrDeleteSelectedNotesContainer(),
                  selectAllContainer()
                ],
                noteListContainer()
              ],
            ),
    );
  }

  Widget readdOrDeleteSelectedNotesContainer() {
    return Padding(
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
                // Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void reAddSelectedItems() {
    reAddAllSelectedNote(notesKeys).then((value) {
      Navigator.of(context).pop();

      if (!value) {
        dialogOnError(context, "Error in Readding Notes");
      }

      setState(() {
        isLoading = true;
      });
      notesKeys = [];
      getTrashNotes();
    });
  }

  Future<void> deleteSelectedItems() async {
    deleteAllPermanently(notesKeys).then((value) {
      Navigator.of(context).pop();

      if (!value) {
        dialogOnError(context, "Error in Deleting Notes");
      }

      setState(() {
        isLoading = true;
      });
      notesKeys = [];
      getTrashNotes();
    });
  }

  Widget selectAllContainer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      child: Row(
        children: [
          Expanded(
            child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Select All'),
              value: selectedItems.every((isSelected) => isSelected),
              onChanged: (value) {
                handleSelectAllChange(value!);
              },
            ),
          ),
        ],
      ),
    );
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
              child: buildNoteCard(context, handleCardCheckBox, null,
                  selectedItems, index, currentNote),
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
}
