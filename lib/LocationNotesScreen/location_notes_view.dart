import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/Helper/helper.dart';
import 'package:to_do_list_app/HomeScreen/edit_note_view.dart';
import 'package:to_do_list_app/HomeScreen/note_content_page.dart';
import 'package:to_do_list_app/LocationNotesScreen/get_current_location.dart';

class LocationNoteView extends StatefulWidget {
  const LocationNoteView({super.key});

  @override
  State<LocationNoteView> createState() => _LocationNoteViewState();
}

class _LocationNoteViewState extends State<LocationNoteView> {
  bool isNotesAvailable = false;
  List<bool> selectedItems = [];
  List<dynamic> notesKeys = [];
  Position currentLocationValue = Position(
    latitude: -180.0,
    longitude: -180.0,
    accuracy: 0.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    timestamp: DateTime.now(),
  );

  List<NoteModel> fetchedNotes = [];
  List<NoteModel> displayedNotes = [];
  TextEditingController searchController = TextEditingController();
  List<NoteModel> filteredNotes = [];
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();

    startLocationMonitoring();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
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
      });
    }
  }

  void startLocationMonitoring() {
    const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best, timeLimit: Duration(minutes: 2));
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position position) {
      currentLocationValue = position;
      notesKeys = [];
      getNotes(currentLocationValue);
    }, onError: (error) => {startLocationMonitoring()});
  }

  void sortByNoteTitle() {
    setState(() {
      displayedNotes.sort((a, b) => a.notetitle.compareTo(b.notetitle));
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCurrentLocation(context).then((location) {
      currentLocationValue = location;
      getNotes(currentLocationValue);
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
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentLocationValue.latitude == -180.0 &&
              currentLocationValue.longitude == -180.0) ...[
            const Center(child: CircularProgressIndicator())
          ] else if (currentLocationValue.latitude == 0.0 &&
              currentLocationValue.longitude == 0.0) ...[
            AlertDialog(
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
            )
          ] else ...[
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                children: [
                  if (fetchedNotes.isNotEmpty) ...[
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
                          return Future.delayed(const Duration(seconds: 1), () {
                            getNotes(currentLocationValue);
                          });
                        },
                        child: ListView.builder(
                          itemCount: displayedNotes.length,
                          itemBuilder: (context, index) {
                            NoteModel currentNote = displayedNotes[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8.0, top: 0, bottom: 0),
                              child: buildNoteCard(context,
                                  currentLocationValue, index, currentNote),
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
        ],
      ),
    );
  }

  Widget buildNoteCard(BuildContext context, Position currentLocation,
      int noteIndex, NoteModel note) {
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
                navigateToNoteEdit(context, note, currentLocation);
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

  void navigateToNoteEdit(
      BuildContext context, NoteModel note, Position currentLocation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        maintainState: false,
        builder: (context) => EditNoteView(noteKey: note.key, note: note),
      ),
    ).then((value) {
      getNotes(currentLocation);
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
}
