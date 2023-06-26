import 'package:flutter/material.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/Helper/helper.dart';
import 'package:to_do_list_app/HomeScreen/note_content_page.dart';

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
    getDeletedData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> getDeletedData() async {
    List<NoteModel> notes = await getDeletedNotes();
    setState(() {
      fetchedNotes = notes;
      displayedNotes = fetchedNotes;
      selectedItems = List.filled(displayedNotes.length, false);
      isLoading = false;
    });
  }

  void sortByNoteTitle() {
    setState(() {
      displayedNotes.sort((a, b) => a.notetitle.compareTo(b.notetitle));
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

  Future<void> deleteSelectedItems() async {
    await deleteAllPermanently(notesKeys);
    setState(() {
      isLoading = true;
    });
    notesKeys = [];
    getDeletedData();
  }

  void reAddSelectedItems() {
    reAddAllSelectedNote(notesKeys).then((value) {
      setState(() {
        isLoading = true;
      });
      getDeletedData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            appBar: AppBar(
              title: const Text("Location Notes"),
              automaticallyImplyLeading: false,
            ),
            body: const Center(child: CircularProgressIndicator()))
        : Scaffold(
            appBar: AppBar(
              title: const Text("Location Notes"),
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
            body: Column(
              children: [
                if (displayedNotes.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              searchHandler(value);
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
                              handleSelectAllChange(value!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (searchController.text.isNotEmpty &&
                    filteredNotes.isEmpty) ...[
                  const Expanded(
                      child: Center(
                    child: Text(
                      'No notes found as per the input entered by you.',
                    ),
                  ))
                ] else if (displayedNotes.isEmpty) ...[
                  const Expanded(
                      child: Center(
                    child: Text("No Notes"),
                  ))
                ] else ...[
                  Expanded(
                      child: ListView.builder(
                    itemCount: displayedNotes.length,
                    itemBuilder: (context, index) {
                      NoteModel currentNote = displayedNotes[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 0, bottom: 0),
                        child: buildNoteCard(context, index, currentNote),
                      );
                    },
                  ))
                ]
              ],
            ),
          );
  }

  Widget buildNoteCard(BuildContext context, int noteIndex, NoteModel note) {
    return GestureDetector(
        onLongPress: () {
          setState(() {
            selectedItems[noteIndex] = true;
            handleCardCheckBox(true, noteIndex, note);
          });
        },
        child: Card(
          child: ListTile(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: getRandomColor(), width: 1),
              borderRadius: BorderRadius.circular(5),
            ),
            leading: selectedItems.contains(true)
                ? Checkbox(
                    value: selectedItems[noteIndex],
                    onChanged: (value) {
                      handleCardCheckBox(value, noteIndex, note);
                    },
                  )
                : null,
            title: Text(note.notetitle),
            onTap: () {
              // Handle tap on note card
              navigateToNoteView(context, note);
            },
          ),
        ));
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
