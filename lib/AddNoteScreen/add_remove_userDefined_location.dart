import 'dart:async';

import 'package:flutter/material.dart';
import 'package:to_do_list_app/Database/userDefined_location_model.dart';
import 'package:to_do_list_app/Map/google_map_view.dart';

typedef SetStateCallBack = void Function(Function());

Future<bool> addNewLocation(BuildContext context, SetStateCallBack setState,
    Map<dynamic, dynamic> userDefinedLocations) async {
  final formKey = GlobalKey<FormState>();
  TextEditingController userDefinedNameforLocationController =
      TextEditingController();
  TextEditingController locationNameController = TextEditingController();
  late String locationCoordinates;
  final completer = Completer<bool>();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          if (!completer.isCompleted) {
            completer.complete(false); // Resolve the completer with false
          }
          return true; // Allow the dialog to be popped
        },
        child: AlertDialog(
          title: const Text('Add Location'),
          content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                        controller: userDefinedNameforLocationController,
                        decoration:
                            const InputDecoration(labelText: 'Location Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Location Name';
                          } else if (userDefinedLocations.isNotEmpty &&
                              userDefinedLocations.entries
                                  .any((entry) => entry.key == value)) {
                            return 'Location Name already exists';
                          }
                          return null;
                        }),
                    const SizedBox(height: 10),
                    TextFormField(
                        onTap: () async {
                          Map<String, String?> locationInfo =
                              await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const GoogleMapView(),
                            ),
                          );

                          setState(() {
                            locationNameController.text =
                                locationInfo['destinationAddress']!;
                            locationCoordinates = locationInfo['coordinates']!;
                          });
                        },
                        readOnly: true,
                        controller: locationNameController,
                        decoration:
                            const InputDecoration(labelText: 'Destination'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter destination';
                          }
                          return null;
                        }),
                  ],
                ),
              )),
          actions: [
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                // Perform the add operation here
                if (formKey.currentState!.validate()) {
                  String userDefinedNameforLocation =
                      userDefinedNameforLocationController.text;
                  String locationName = locationNameController.text;

                  addLocation(userDefinedNameforLocation, locationName,
                          locationCoordinates)
                      .then((value) {
                    formKey.currentState!.reset();
                    // Close the alert dialog
                    Navigator.of(context).pop();
                    completer.complete(true);
                  });
                }
              },
            ),
          ],
        ),
      );
    },
  );
  return await completer.future;
}

Future<bool> removeLocation(BuildContext context, SetStateCallBack setState,
    Map<dynamic, dynamic> userDefinedLocations) async {
  final formKey = GlobalKey<FormState>();
  dynamic selectedLocation;
  final completer = Completer<bool>();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          if (!completer.isCompleted) {
            completer.complete(false); // Resolve the completer with false
          }
          return true; // Allow the dialog to be popped
        },
        child: AlertDialog(
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
                  items: userDefinedLocations.entries.map((location) {
                    return DropdownMenuItem<String>(
                      value: location.key,
                      child: Text(location.key),
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
                    formKey.currentState!.reset();
                    Navigator.of(context).pop();
                    completer.complete(true);
                  });
                  // Close the alert dialog
                }
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    },
  );
  return await completer.future;
}
