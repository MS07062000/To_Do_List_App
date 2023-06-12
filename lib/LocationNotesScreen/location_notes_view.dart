import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:to_do_list_app/HomeScreen/note_content_page.dart';
import 'package:to_do_list_app/LocationNotesScreen/getCurrentLocation.dart';
import '../Database/note_model.dart';

class LocationNoteView extends StatefulWidget {
  @override
  _LocationNoteViewState createState() => _LocationNoteViewState();
}

class _LocationNoteViewState extends State<LocationNoteView> {
  bool isLoading = true;
  Box<NoteModel>? noteBox; // Declare a reference to the Hive box
  Future<Position>? currentLocation;

  @override
  void initState() {
    super.initState();
    openHiveBox(); // Open the Hive box when the state is initialized
  }

  Future<void> openHiveBox() async {
    await initializeHive();
    registerHiveAdapters();
    final box = await Hive.openBox<NoteModel>('notes');
    setState(() {
      noteBox = box;
      // isLoading = false;
    });
    await getLocation();
  }

  Future<void> getLocation() async {
    setState(() {
      currentLocation = getCurrentLocation(context);
      isLoading = false;
      // print(isLoading);
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    // if (currentLocation.latitude == 0.0 && currentLocation!.longitude == 0.0) {
    //   return const Center(
    //       child: Text(
    //           'Please enable both location services and permissions to use this feature.'));
    // }
    return FutureBuilder<Position>(
      future: currentLocation,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error occurred: ${snapshot.error}'));
        } else if (snapshot.data == null ||
            snapshot.data!.latitude == 0.0 && snapshot.data!.longitude == 0.0) {
          return const Center(
              child: Text(
                  'Please enable both location services and permissions to use this feature.'));
        } else {
          return Column(
            children: [
              Expanded(
                child: ValueListenableBuilder<List<NoteModel>>(
                  valueListenable: findNotesFromDestination(
                      noteBox!, snapshot.data!, 1000.00),
                  builder: (context, list, _) {
                    if (list.isEmpty) {
                      return const Center(
                        child: Text("No Notes"),
                      );
                    }

                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        NoteModel currentNote = list[index];
                        return Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                            child: buildNoteCard(context, currentNote));
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
}

Widget buildNoteCard(BuildContext context, NoteModel note) {
  return Card(
    child: ListTile(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: _getRandomColor(), width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      leading: Text(note.notetitle),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          )
        ],
        onSelected: (value) {
          if (value == 'edit') {
            // Handle 'Edit' option
          } else if (value == 'delete') {
            // Handle 'Delete' option
            deleteNote(context, note);
          }
        },
      ),
      onTap: () {
        // Handle tap on note card
        navigateToNoteView(context, note);
      },
    ),
  );
}

ValueNotifier<List<NoteModel>> findNotesFromDestination(
    Box<NoteModel> noteBox, Position currentLocation, double maxDistance) {
  // Get the latitude and longitude of the current location
  double currentLatitude = currentLocation.latitude;
  double currentLongitude = currentLocation.longitude;

  // Filter the notes based on the distance from the current location
  List<NoteModel> filteredNotes = noteBox.values.where((note) {
    double noteLatitude = double.parse(note.destination.split(',')[0]);
    double noteLongitude =
        double.parse(note.destination.split(',')[1]); //note.destination;

    // Calculate the distance between the current location and note's destination
    double distanceInMeters = Geolocator.distanceBetween(
      currentLatitude,
      currentLongitude,
      noteLatitude,
      noteLongitude,
    );

    // Filter the notes within the maximum distance
    return distanceInMeters <= maxDistance;
  }).toList();

  // Perform further operations with the filtered notes
  // For example, display the filtered notes in a list or on the map
  return ValueNotifier<List<NoteModel>>(filteredNotes);
}

void navigateToNoteView(BuildContext context, NoteModel note) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NoteContentPage(note: note),
    ),
  );
}

void deleteNote(BuildContext context, NoteModel note) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text(
          "Do you want to delete ${note.notetitle}?",
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Yes"),
            onPressed: () async {
              await Hive.box<NoteModel>('notes').delete(note.key);
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
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
