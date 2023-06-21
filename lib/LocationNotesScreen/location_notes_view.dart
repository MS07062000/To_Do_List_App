import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:provider/provider.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/HomeScreen/edit_note_view.dart';
import 'package:to_do_list_app/HomeScreen/note_content_page.dart';
import 'package:to_do_list_app/LocationNotesScreen/get_current_location.dart';
// import 'package:to_do_list_app/Main/bottom_navbar_provider.dart';

class LocationNoteView extends StatefulWidget {
  const LocationNoteView({super.key});

  @override
  State<LocationNoteView> createState() => _LocationNoteViewState();
}

class _LocationNoteViewState extends State<LocationNoteView> {
  // bool isLoading = true;
  bool isNotesAvailable = false;
  List<bool> selectedItems = [];
  List<dynamic> notesKeys = [];
  final currentLocationValue = ValueNotifier<Position?>(null);
  // ValueNotifier<List<NoteModel>> notesNotifier =
  //     ValueNotifier<List<NoteModel>>([]);
  List<NoteModel> fetchedNotes = [];
  List<NoteModel> displayedNotes = [];
  TextEditingController searchController = TextEditingController();
  List<NoteModel> filteredNotes = [];
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    // Provider.of<BottomNavBarProvider>(context, listen: false)
    //     .refreshNotifier
    //     .addListener(_refreshNotes);
    // notesNotifier.addListener(() {
    //   if (notesNotifier.value.isEmpty) {
    //     isNotesAvailable = false;
    //   } else {
    //     isNotesAvailable = true;
    //   }
    //});

    startLocationMonitoring();
  }

  @override
  void dispose() {
    // Provider.of<BottomNavBarProvider>(context, listen: false)
    //     .refreshNotifier
    //     .removeListener(_refreshNotes);
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // void _refreshNotes() {
  //   if (!Provider.of<BottomNavBarProvider>(context, listen: false)
  //       .refreshNotifier
  //       .value) {
  //     return;
  //   }
  //   if (mounted) {
  //     getCurrentLocation(context).then((location) {
  //       currentLocationValue.value = location;
  //       getNotes(currentLocationValue.value);
  //     });
  //   }
  //   Provider.of<BottomNavBarProvider>(context, listen: false)
  //       .refreshNotifier
  //       .value = false;
  // }

  Future<void> getNotes(currentLocation) async {
    // notesNotifier = ValueNotifier<List<NoteModel>>(
    //     await findNotesFromDestination(currentLocation, 500.00, false));
    // selectedItems = List.filled(notesNotifier.value.length, false);
    List<NoteModel> notes =
        await findNotesFromDestination(currentLocation, 500.00, false);
    if (mounted) {
      setState(() {
        fetchedNotes = notes;
        displayedNotes = fetchedNotes;
        selectedItems = List.filled(displayedNotes.length, false);
      });
    }
  }

  void startLocationMonitoring() {
    const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best, timeLimit: Duration(seconds: 30));
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      currentLocationValue.value = position;
      getNotes(currentLocationValue.value);
    });
  }

  void sortByNoteTitle() {
    setState(() {
      displayedNotes.sort((a, b) => a.notetitle.compareTo(b.notetitle));
    });
  }

  void handleSelectAllChange(bool? selectAll) {
    setState(() {
      selectedItems = List.filled(displayedNotes.length, selectAll ?? false);
      // List.filled(notesNotifier.value.length, selectAll ?? false);
      if (selectAll!) {
        notesKeys = List.filled(
            displayedNotes.length, (index) => displayedNotes[index].key);
      } else {
        notesKeys = [];
      }
      // Provider.of<BottomNavBarProvider>(context, listen: false)
      //     .setNotesKeys(notesKeys);
    });
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
    return Scaffold(
      appBar: AppBar(title: const Text('Location Notes'), actions: [
        Row(
          children: [
            if (displayedNotes.isNotEmpty) ...[
              //notesNotifier.value.
              IconButton(
                icon: const Icon(Icons.sort_by_alpha),
                onPressed: () {
                  sortByNoteTitle();
                },
              ),
            ],
            const SizedBox(width: 8),
            if (notesKeys.isNotEmpty) ...[
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
      body: ValueListenableBuilder<Position?>(
        valueListenable: currentLocationValue,
        builder: (context, value, child) {
          if (value == null) {
            return const Center(child: CircularProgressIndicator());
          } else if (value.latitude == 0.0 && value.longitude == 0.0) {
            return AlertDialog(
              title: const Text('Location Services Or Permissions Disabled'),
              content: const Text(
                  'Please enable both location services and permissions to use this feature.'),
              actions: [
                TextButton(
                  child: const Text('Open Settings'),
                  onPressed: () {
                    // Open device settings
                    Geolocator.openAppSettings();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          } else {
            return Column(
              children: [
                if (fetchedNotes.isNotEmpty) ...[
                  //notesNotifier.value
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
                                filteredNotes =
                                    displayedNotes //notesNotifier.value
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
                              value: selectedItems
                                  .every((isSelected) => isSelected),
                              onChanged: (value) {
                                handleSelectAllChange(value);
                              },
                            ),
                          ),
                        ),
                      ],
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
                // Expanded(
                //   child: ValueListenableBuilder<List<NoteModel>>(
                //     valueListenable: notesNotifier,
                //     builder: (context, list, _) {
                //       List<NoteModel> displayedNotes =
                //           searchController.text.isEmpty ? list : filteredNotes;

                //       if (isNotesAvailable &&
                //           searchController.text.isEmpty &&
                //           displayedNotes.isEmpty) {
                //         // Provider.of<BottomNavBarProvider>(context, listen: false)
                //         //     .isNotesAvailable
                //         //     .value = false;
                //         return const Center(
                //           child: Text("No Notes Available for this Location"),
                //         );
                //       }

                //       if (isNotesAvailable &&
                //           searchController.text.isNotEmpty &&
                //           displayedNotes.isEmpty) {
                //         // Provider.of<BottomNavBarProvider>(context, listen: false)
                //         //     .isNotesAvailable
                //         //     .value = false;
                //         return const Center(
                //           child: Text(
                //             'No notes found as per the input entered by you.',
                //           ),
                //         );
                //       }

                //       // Provider.of<BottomNavBarProvider>(context, listen: false)
                //       //     .isNotesAvailable
                //       //     .value = true;
                //       return ListView.builder(
                //         itemCount: displayedNotes.length,
                //         itemBuilder: (context, index) {
                //           NoteModel currentNote = displayedNotes[index];
                //           return Padding(
                //               padding: const EdgeInsets.only(
                //                   left: 8.0, right: 8.0, top: 0, bottom: 0),
                //               child:
                //                   buildNoteCard(context, index, currentNote));
                //         },
                //       );
                //     },
                //   ),
                // ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildNoteCard(BuildContext context, int noteIndex, NoteModel note) {
    return GestureDetector(
        onLongPress: () {
          setState(() {
            selectedItems[noteIndex] = true;
            handleCardCheckBox(selectedItems[noteIndex], noteIndex, note);
          });
        },
        child: Card(
          child: ListTile(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: _getRandomColor(), width: 1),
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

  void navigateToNoteEdit(BuildContext context, NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        maintainState: false,
        builder: (context) => EditNoteView(noteKey: note.key, note: note),
      ),
    ).then((value) {
      didChangeDependencies();
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
                  // Provider.of<BottomNavBarProvider>(context, listen: false)
                  //     .refreshNotifier
                  //     .value = true;
                  didChangeDependencies();
                  Navigator.of(context).pop();
                });
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


