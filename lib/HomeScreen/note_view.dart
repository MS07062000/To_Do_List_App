import 'dart:async';
import 'package:to_do_list_app/Database/predefined_location_model.dart';
import 'package:to_do_list_app/Helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:to_do_list_app/HomeScreen/edit_note_view.dart';
import 'package:to_do_list_app/HomeScreen/note_content_page.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/LocationNotesScreen/get_current_location.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => NoteViewState();
}

class NoteViewState extends State<NoteView> {
  bool isLoading = true;
  bool isLocationServicesAvailable = false;
  // late ValueNotifier<List<NoteModel>> notesNotifier;
  List<bool> selectedItems = [];
  List<dynamic> notesKeys = [];
  TextEditingController searchController = TextEditingController();
  List<NoteModel> fetchedNotes = [];
  List<NoteModel> displayedNotes = [];
  List<NoteModel> filteredNotes = [];
  List<dynamic> preDefinedLoations = [];
  @override
  void initState() {
    super.initState();
    getNotes();
    setpreDefinedLocation();

    // Provider.of<BottomNavBarProvider>(context, listen: false)
    //     .refreshNotifier
    //     .addListener(_refreshNotes);
  }

  @override
  void dispose() {
    // Provider.of<BottomNavBarProvider>(context, listen: false)
    //     .refreshNotifier
    //     .addListener(_refreshNotes);
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
  //     getNotes();
  //   }
  //   Provider.of<BottomNavBarProvider>(context, listen: false)
  //       .refreshNotifier
  //       .value = false;
  // }

  Future<void> getNotes() async {
    // notesNotifier = ValueNotifier<List<NoteModel>>(await getUnreadNotes());
    //  selectedItems = List.filled(notesNotifier.value.length, false);

    List<NoteModel> notes = await getUnreadNotes();
    setState(() {
      fetchedNotes = notes;
      displayedNotes = fetchedNotes;
      selectedItems = List.filled(displayedNotes.length, false);
      locationPermissionAndServicesEnabled().then((value) {
        if (value) {
          isLocationServicesAvailable = true;
        } else {
          isLocationServicesAvailable = false;
        }
      });
      isLoading = false;
    });
  }

  Future<void> setpreDefinedLocation() async {
    List<dynamic> fetchedpreDefinedLocation = await getPredefinedLocations();
    setState(() {
      preDefinedLoations = fetchedpreDefinedLocation;
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
      displayedNotes.sort((a, b) => a.notetitle.compareTo(b.notetitle));
    });
  }

  void sortByLocation() {
    if (isLocationServicesAvailable) {
      setState(() {
        displayedNotes.sort((a, b) {
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
      });
    }
  }

  void handleLocationOperation(String locationOperation) {
    if (locationOperation == 'addLocation') {
      addNewLocation(context);
      setpreDefinedLocation();
    }

    if (locationOperation == 'removeLocation') {
      removeLocation(context, preDefinedLoations);
    }
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
                  Row(
                    children: [
                      PopupMenuButton(
                        icon: const Icon(Icons.sort),
                        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                          const PopupMenuItem(
                            value: 'noteTitle',
                            child: Text('Sort by Note Title'),
                          ),
                          if (isLocationServicesAvailable)
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
                      const SizedBox(width: 4),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                          const PopupMenuItem(
                            value: 'addLocation',
                            child: Text('Add Location'),
                          ),
                          if (preDefinedLoations.isNotEmpty)
                            const PopupMenuItem(
                              value: 'removeLocation',
                              child: Text('Delete Location'),
                            )
                        ],
                        onSelected: (selectedOption) {
                          handleLocationOperation(selectedOption);
                        },
                      ),
                    ],
                  )
                ]
              ],
            ),
            body: Column(
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
                ]
                // ] else if (searchController.text.isNotEmpty &&
                //     filteredNotes.isNotEmpty) ...[
                //   Expanded(
                //       child: ListView.builder(
                //     itemCount: filteredNotes.length,
                //     itemBuilder: (context, index) {
                //       NoteModel currentNote = filteredNotes[index];
                //       return Padding(
                //         padding: const EdgeInsets.only(
                //             left: 8.0, right: 8.0, top: 0, bottom: 0),
                //         child: buildNoteCard(context, index, currentNote),
                //       );
                //     },
                //   ))
                // ]
                else ...[
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
                //     builder: (context, notes, _) {
                //       displayedNotes = searchController.text.isEmpty
                //           ? notes
                //           : displayedNotes;

                //       if (notes.isEmpty)
                //         return const Center(
                //           child: Text("No Notes"),
                //         );
                //       }

                //       if (displayedNotes.isEmpty) {
                //         return const Center(
                //           child: Text(
                //             'No notes found as per the input entered by you.',
                //           ),
                //         );
                //       }

                //     },
                //   ),
                // ),
              ],
            ));
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
      // print(notesKeys);
      // Provider.of<BottomNavBarProvider>(context, listen: false)
      //     .setNotesKeys(notesKeys);
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
                  notesKeys = [];
                  getNotes();
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void addNewLocation(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    TextEditingController locationController = TextEditingController();
    TextEditingController coordinatesController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Location'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                    controller: locationController,
                    decoration:
                        const InputDecoration(labelText: 'Location Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Location Name';
                      } else if (preDefinedLoations.isNotEmpty &&
                          preDefinedLoations.contains(value)) {
                        return 'Location Name already exists';
                      }
                      return null;
                    }),
                const SizedBox(height: 10),
                TextFormField(
                    controller: coordinatesController,
                    decoration: const InputDecoration(labelText: 'Coordinates'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter coordinates';
                      }
                      return null;
                    }),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                // Perform the add operation here
                if (formKey.currentState!.validate()) {
                  String locationName = locationController.text;
                  String coordinates = coordinatesController.text;

                  addLocation(locationName, coordinates).then((value) {
                    formKey.currentState!.reset();
                    // Close the alert dialog
                    Navigator.of(context).pop();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void removeLocation(BuildContext context, List<dynamic> locations) {
    final formKey = GlobalKey<FormState>();
    dynamic selectedLocation;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Location'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  menuMaxHeight: 150,
                  value: selectedLocation,
                  onChanged: (value) {
                    setState(() {
                      selectedLocation = value;
                    });
                  },
                  items: locations.map((location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Select Location',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a location';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate() &&
                    selectedLocation != null) {
                  // Perform the delete operation here
                  // Delete the selected location from the database
                  deleteLocation(selectedLocation!).then((value) {
                    setpreDefinedLocation();
                    Navigator.of(context).pop();
                  });
                  // Close the alert dialog
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
