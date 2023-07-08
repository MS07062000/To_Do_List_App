import 'dart:async';
// import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/Helper/helper.dart';
import 'package:to_do_list_app/HomeScreen/edit_note_view.dart';
import 'package:to_do_list_app/HomeScreen/note_content_page.dart';

class LocationNoteView extends StatefulWidget {
  const LocationNoteView({super.key});

  @override
  State<LocationNoteView> createState() => _LocationNoteViewState();
}

class _LocationNoteViewState extends State<LocationNoteView> {
  bool isLoading = true;
  bool isNotesAvailable = false;
  List<bool> selectedItems = [];
  List<dynamic> notesKeys = [];
  List<NoteModel> fetchedNotes = [];
  List<NoteModel> displayedNotes = [];
  TextEditingController searchController = TextEditingController();
  List<NoteModel> filteredNotes = [];
  StreamSubscription<LocationData>? locationStreamSubscription;

  @override
  void initState() {
    super.initState();
    startLocationMonitoring();
  }

  @override
  void dispose() {
    locationStreamSubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> getNotes(currentLocation) async {
    List<NoteModel> notes =
        await findNotesFromDestination(currentLocation, 50.00, false);
    if (mounted) {
      setState(() {
        fetchedNotes = notes;
        displayedNotes = fetchedNotes;
        selectedItems = List.filled(displayedNotes.length, false);
        isLoading = false;
      });
    }
  }

  void startLocationMonitoring() {
    locationStreamSubscription?.cancel();
    // locationPermissionAndServicesEnabled().then((isEnabled) => {
    //       locationStreamSubscription = Location()
    //           .onLocationChanged
    //           .listen((LocationData location) async {
    //         log('${location.latitude},${location.longitude}');
    //         log(DateTime.timestamp().toString());
    //         await getNotes(location);
    //         locationStreamSubscription?.pause(Future<void>(() async {
    //           log(DateTime.timestamp().toString());
    //           await Future.delayed(const Duration(seconds: 30),
    //               locationStreamSubscription?.resume);
    //         }));
    //       })
    //     });
    locationPermissionAndServicesEnabled().then((isPermissionEnabled) {
      // log(isPermissionEnabled.toString());
      if (isPermissionEnabled) {
        Location().changeSettings(interval: 30000).then((isSettingsChanged) {
          if (isSettingsChanged) {
            // log("settings");
            // log(isSettingsChanged.toString());
            locationStreamSubscription = Location()
                .onLocationChanged
                .listen((LocationData location) async {
              // log("Inside location");
              // log('${location.latitude},${location.longitude}');
              getNotes(location);
            });
          }
        });
      } else {
        startLocationMonitoring();
      }
    });
  }

  void sortByNoteTitle() {
    setState(() {
      displayedNotes.sort((a, b) =>
          a.notetitle.toLowerCase().compareTo(b.notetitle.toLowerCase()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Notes'), actions: [
        Row(
          children: [
            if (displayedNotes.isNotEmpty) ...[
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    children: [
                      if (fetchedNotes.isNotEmpty) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    10.0, 5.0, 10.0, 5.0),
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (value) {
                                    setState(() {
                                      filteredNotes = displayedNotes
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
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 5.0, 10.0, 5.0),
                                  child: CheckboxListTile(
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: const Text('Select All'),
                                    value: selectedItems
                                        .every((isSelected) => isSelected),
                                    onChanged: (value) {
                                      handleSelectAllChange(value!);
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
                          child: RefreshIndicator(
                            onRefresh: () {
                              return Future.delayed(const Duration(seconds: 1),
                                  () {
                                startLocationMonitoring();
                              });
                            },
                            child: ListView.builder(
                              itemCount: displayedNotes.length,
                              itemBuilder: (context, index) {
                                NoteModel currentNote = displayedNotes[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0, top: 0, bottom: 0),
                                  child: buildNoteCard(
                                      context, index, currentNote),
                                );
                              },
                            ),
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              ],
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
      startLocationMonitoring();
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
                  notesKeys = [];
                  startLocationMonitoring();
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
