import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/HomeScreen/note_content_page.dart';
import 'package:to_do_list_app/LocationNotesScreen/get_current_location.dart';
import 'package:to_do_list_app/main.dart';
import '../Database/note_model.dart';
import '../HomeScreen/edit_note_view.dart';

class LocationNoteView extends StatefulWidget {
  const LocationNoteView({super.key});

  @override
  State<LocationNoteView> createState() => _LocationNoteViewState();
}

class _LocationNoteViewState extends State<LocationNoteView> {
  // bool isLoading = true;
  bool selectAll = false;
  List<bool> selectedItems = [];
  List<dynamic> notesKeys = [];
  final currentLocationValue = ValueNotifier<Position?>(null);
  ValueNotifier<List<NoteModel>> notesNotifier =
      ValueNotifier<List<NoteModel>>([]);
  TextEditingController searchController = TextEditingController();
  List<NoteModel> filteredNotes = [];

  @override
  void initState() {
    super.initState();
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
      getCurrentLocation(context).then((location) {
        currentLocationValue.value = location;
        getNotes(currentLocationValue.value);
      });
    }
    Provider.of<BottomNavBarProvider>(context, listen: false)
        .refreshNotifier
        .value = false;
  }

  Future<void> getNotes(currentLocation) async {
    notesNotifier = ValueNotifier<List<NoteModel>>(
        await findNotesFromDestination(currentLocation, 1000.00));
    selectedItems = List.filled(notesNotifier.value.length, false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCurrentLocation(context).then((location) {
      currentLocationValue.value = location;
      getNotes(currentLocationValue.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Position?>(
      valueListenable: currentLocationValue,
      builder: (context, value, child) {
        if (value == null) {
          return const Center(child: CircularProgressIndicator());
        } else if (value.latitude == 0.0 && value.longitude == 0.0) {
          return const Padding(
              padding: EdgeInsets.all(2.0),
              child: Text(
                  'Please enable both location services and permissions to use this feature.'));
        } else {
          return Column(
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
                  builder: (context, list, _) {
                    List<NoteModel> displayedNotes =
                        searchController.text.isEmpty ? list : filteredNotes;

                    if (list.isEmpty) {
                      return const Center(
                        child: Text("No Notes Available for this Location"),
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
                            child: buildNoteCard(context, index, currentNote));
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
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

  void navigateToNoteEdit(BuildContext context, NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        maintainState: false,
        builder: (context) => EditNoteView(noteKey: note.key, note: note),
      ),
    ).then((value) {});
  }

  void navigateToNoteView(BuildContext context, NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteContentPage(note: note),
      ),
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




 //   if (notesNotifier.value.isNotEmpty) ...[
              //     CheckboxListTile(
              //       controlAffinity: ListTileControlAffinity.leading,
              //       title: const Text('Select All'),
              //       value: selectedItems.every((isSelected) => isSelected),
              //       onChanged: (value) {
              //         setState(() {
              //           selectedItems = List.filled(
              //               notesNotifier.value.length, value ?? false);
              //         });
              //       },
              //     ),
              //   ],










// void deleteNote(BuildContext context, NoteModel note) {
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
//             onPressed: () async {
//               final navigator = Navigator.of(context);
//               await Hive.box<NoteModel>('notes').delete(note.key);
//               navigator.pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }


