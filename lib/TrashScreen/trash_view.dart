import 'package:flutter/material.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/Helper/helper.dart';
import 'package:to_do_list_app/HomeScreen/note_content_page.dart';
// import 'package:provider/provider.dart';
// import 'package:to_do_list_app/Main/bottom_navbar_provider.dart';

class TrashView extends StatefulWidget {
  const TrashView({super.key});
  @override
  State<TrashView> createState() => _TrashViewState();
}

class _TrashViewState extends State<TrashView> {
  bool isLoading = true;
  // bool isNotesAvailable = false;
  // late ValueNotifier<List<NoteModel>> notesNotifier;
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
    // Provider.of<BottomNavBarProvider>(context, listen: false)
    //     .refreshNotifier
    //     .addListener(_refreshNotes);
  }

  @override
  void dispose() {
    // Provider.of<BottomNavBarProvider>(context, listen: false)
    //     .refreshNotifier
    //     .addListener(_refreshNotes);
    searchController.dispose();
    super.dispose();
  }

  // void _refreshNotes() {
  //   if (!Provider.of<BottomNavBarProvider>(context, listen: false)
  //       .refreshNotifier
  //       .value) {
  //     return;
  //   }
  //   if (mounted) {
  //     setState(() {
  //       isLoading = true;
  //     });
  //     getDeletedData();
  //   }

  //   Provider.of<BottomNavBarProvider>(context, listen: false)
  //       .refreshNotifier
  //       .value = false;
  // }

  Future<void> getDeletedData() async {
    // notesNotifier = ValueNotifier<List<NoteModel>>(await getDeletedNotes());
    // selectedItems = List.filled(notesNotifier.value.length, false);
    List<NoteModel> notes = await getDeletedNotes();
    setState(() {
      fetchedNotes = notes;
      displayedNotes = fetchedNotes;
      selectedItems = List.filled(displayedNotes.length, false);
      isLoading = false;
    });
  }

  void sortByNoteTitle() {
    //List<NoteModel> notes
    setState(() {
      displayedNotes.sort((a, b) => a.notetitle.compareTo(b.notetitle));
    });
    // notes.sort((a, b) => a.notetitle.compareTo(b.notetitle));
  }

  void searchHandler(String input) {
    setState(() {
      filteredNotes = fetchedNotes //notesNotifier.value
          .where((note) =>
              note.notetitle.toLowerCase().contains(input.toLowerCase()))
          .toList();
      displayedNotes = filteredNotes;
    });
  }

  void handleSelectAllChange(bool selectAll) {
    setState(() {
      selectedItems = List.filled(displayedNotes.length, selectAll);
      // List.filled(notesNotifier.value.length, selectAll ?? false);
      if (selectAll) {
        notesKeys = displayedNotes.map((note) => note.key).toList();
      } else {
        notesKeys = [];
      }
      // Provider.of<BottomNavBarProvider>(context, listen: false)
      //     .setNotesKeys(notesKeys);
    });
  }

  Future<void> deleteSelectedItems() async {
    await deleteAllPermanently(notesKeys);
    setState(() {
      isLoading = true;
    });
    notesKeys = [];
    getDeletedData();
    // Provider.of<BottomNavBarProvider>(context, listen: false)
    //     .refreshNotifier
    //     .value = true;
  }

  void reAddSelectedItems() {
    // Provider.of<BottomNavBarProvider>(context, listen: false).noteKeys
    reAddAllSelectedNote(notesKeys).then((value) {
      setState(() {
        isLoading = true;
      });
      getDeletedData();

      // Provider.of<BottomNavBarProvider>(context, listen: false)
      //     .refreshNotifier
      //     .value = true;
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
                  //if (isNotesAvailable) ...[
                  IconButton(
                    icon: const Icon(Icons.sort_by_alpha),
                    onPressed: () {
                      sortByNoteTitle(); //notesNotifier.value
                    },
                  ),
                  const SizedBox(width: 8),
                ]
              ],
            ),
            body: Column(
              children: [
                if (displayedNotes.isNotEmpty) ...[
                  // if (notesNotifier.value.isNotEmpty) ...[
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
                //   Expanded(
                //     child: ValueListenableBuilder<List<NoteModel>>(
                //       valueListenable: notesNotifier,
                //       builder: (context, notes, _) {
                //         List<NoteModel> displayedNotes =
                //             searchController.text.isEmpty ? notes : filteredNotes;

                //         if (notes.isEmpty) {
                //           return const Center(
                //             child: Text("No Notes"),
                //           );
                //         }

                //         if (displayedNotes.isEmpty) {
                //           return const Center(
                //             child: Text(
                //               'No notes found as per the input entered by you.',
                //             ),
                //           );
                //         }

                //         return ListView.builder(
                //           itemCount: displayedNotes.length,
                //           itemBuilder: (context, index) {
                //             NoteModel currentNote = displayedNotes[index];
                //             return Padding(
                //                 padding: const EdgeInsets.only(
                //                     left: 8.0, right: 8.0, top: 0, bottom: 0),
                //                 child:
                //                     buildNoteCard(context, index, currentNote));
                //           },
                //         );
                //       },
                //     ),
                //   ),
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
      // Provider.of<BottomNavBarProvider>(context, listen: false)
      //     .setNotesKeys(notesKeys);
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

  void deletePermanentlyTheDeletedNotes(
      BuildContext context, List<dynamic> notesKeys) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
            "Do you want to delete all notes permanently?",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("No"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                // final navigator = Navigator.of(context);
                deleteAllPermanently(notesKeys).then((value) {
                  // Provider.of<BottomNavBarProvider>(context, listen: false)
                  //     .refreshNotifier
                  //     .value = true;
                  getDeletedNotes();
                  Navigator.of(context).pop();
                });
                // navigator.pop();
              },
            ),
          ],
        );
      },
    );
  }
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