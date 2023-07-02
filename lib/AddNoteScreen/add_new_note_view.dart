import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:to_do_list_app/Database/predefined_location_model.dart';
import 'package:to_do_list_app/Main/bottom_navbar_provider.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/Map/google_map_view.dart';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// import 'package:to_do_list_app/Map/osm_map_view.dart';

class AddNewNoteView extends StatefulWidget {
  final NoteModel? note;
  final dynamic noteKey;
  const AddNewNoteView({Key? key, this.noteKey, this.note}) : super(key: key);

  @override
  State<AddNewNoteView> createState() => _AddNewNoteViewState();
}

class _AddNewNoteViewState extends State<AddNewNoteView> {
  final formKey = GlobalKey<FormState>();
  String _destinationType = 'predefinedLocation';
  dynamic _selectedLocation;
  List<dynamic> predefinedLocations = [];
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _textNoteController = TextEditingController();
  final List<TextEditingController> _checkListController = [];
  String _noteType = 'Text';
  final List<String> _checklistItems = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    setPredefinedLocation();
    if (widget.note != null) {
      // Initialize the form fields with the values from the existing note
      _destinationType = 'map';
      _destinationController.text = widget.note!.destination;
      _setSelectedLocation(widget.note!.destination);

      _noteTitleController.text = widget.note!.notetitle;
      if (widget.note!.textnote != null) {
        _textNoteController.text = widget.note!.textnote!;
      }

      if (widget.note!.checklist != null) {
        _checklistItems.addAll(widget.note!.checklist!);
        _checkListController.addAll(List.generate(
          widget.note!.checklist!.length,
          (_) => TextEditingController(),
        ));
        for (int i = 0; i < widget.note!.checklist!.length; i++) {
          _checkListController[i].text = widget.note!.checklist![i];
        }
        _noteType = 'CheckList';
      } else {
        _checkListController
            .addAll([TextEditingController(), TextEditingController()]);
        _checklistItems.addAll(['', '']);
      }
    } else {
      _checkListController
          .addAll([TextEditingController(), TextEditingController()]);
      _checklistItems.addAll(['', '']);
      _setSelectedLocation(null);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _destinationController.dispose();
    _noteTitleController.dispose();
    _textNoteController.dispose();
    super.dispose();
  }

  void _setSelectedLocation(String? coordinates) async {
    if (coordinates != null) {
      var locationName = await getLocation(coordinates);
      if (locationName.isNotEmpty) {
        setState(() {
          _selectedLocation = locationName;
          _destinationController.text = '';
          _destinationType = 'predefinedLocation';
        });
      }
    } else {
      if (predefinedLocations.isNotEmpty) {
        setState(() {
          _selectedLocation = predefinedLocations[0];
          _destinationType = 'map';
        });
      }
    }
  }

  Future<void> setPredefinedLocation() async {
    List<dynamic> locationList = await getPredefinedLocations();
    setState(() {
      predefinedLocations = locationList;
    });
  }

  void _onDestinationTypeChanged(String isPredefinedLocation) {
    setState(() {
      _destinationType = isPredefinedLocation;
    });
  }

  void _onDestinationTap() async {
    // GeoPoint latLng = await Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => const OSMMapView(),
    //   ),
    // );
    // setState(() {
    //   _destinationController.text = '${latLng.latitude}, ${latLng.longitude}';
    // });
    String latLng = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GoogleMapView(),
      ),
    );

    setState(() {
      _destinationController.text = latLng;
    });
  }

  void _onPredefinedLocation(location) async {
    String locationCoordinates = await getCoordinates(location);
    setState(() {
      _selectedLocation = location;
      _destinationController.text = locationCoordinates;
    });
  }

  void _onNoteTypeChanged(String isText) {
    setState(() {
      _noteType = isText;
    });
  }

  void _onAddChecklistItem() {
    setState(() {
      _checkListController.add(TextEditingController());
      _checklistItems.add('');
    });
  }

  void _onRemoveChecklistItem(int index) {
    setState(() {
      _checkListController.removeAt(index);
      _checklistItems.removeAt(index);
    });
  }

  void handleLocationOperation(String locationOperation) {
    if (locationOperation == 'addLocation') {
      addNewLocation(context);
    }

    if (locationOperation == 'removeLocation') {
      removeLocation(context, predefinedLocations);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: widget.note == null
          ? AppBar(
              title: const Text('Location Notes'),
              automaticallyImplyLeading: false,
              actions: [
                const SizedBox(width: 4),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    const PopupMenuItem(
                      value: 'addLocation',
                      child: Text('Add Location'),
                    ),
                    if (predefinedLocations.isNotEmpty)
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
          : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (predefinedLocations.isNotEmpty) ...[
                  const Text(
                    'Select Destination From :',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: const Text('Default Location'),
                          value: 'predefinedLocation',
                          groupValue: _destinationType,
                          onChanged: ((value) =>
                              _onDestinationTypeChanged(value!)),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          title: const Text('Map'),
                          value: 'map',
                          groupValue: _destinationType,
                          onChanged: ((value) =>
                              _onDestinationTypeChanged(value!)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  if (_destinationType == 'map')
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                        suffixIcon: Icon(Icons.map),
                        border: OutlineInputBorder(),
                      ),
                      controller: _destinationController,
                      onTap: _onDestinationTap,
                      readOnly: true,
                    )
                  else
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Location',
                      ),
                      icon: const Icon(Icons.arrow_drop_down),
                      menuMaxHeight: 150,
                      items: predefinedLocations
                          .map<DropdownMenuItem<dynamic>>((dynamic value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(fontSize: 20),
                          ),
                        );
                      }).toList(),
                      value: _selectedLocation,
                      onChanged: (value) => _onPredefinedLocation(value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a Location';
                        }
                        return null;
                      },
                    ),
                ] else ...[
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Destination',
                      suffixIcon: Icon(Icons.map),
                      border: OutlineInputBorder(),
                    ),
                    controller: _destinationController,
                    onTap: _onDestinationTap,
                    readOnly: true,
                  )
                ],
                const SizedBox(height: 16.0),
                TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    controller: _noteTitleController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    }),
                const SizedBox(height: 16.0),
                const Text(
                  'Select Type Of Note',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: const Text('Text'),
                        value: 'Text',
                        groupValue: _noteType,
                        onChanged: ((value) => _onNoteTypeChanged(value!)),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        title: const Text('CheckList'),
                        value: 'CheckList',
                        groupValue: _noteType,
                        onChanged: ((value) => _onNoteTypeChanged(value!)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                if (_noteType == 'Text')
                  TextFormField(
                    maxLines: null,
                    minLines: 4,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      labelText: 'Text Note',
                      border: OutlineInputBorder(),
                    ),
                    controller: _textNoteController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please fill text Note';
                      }
                      return null;
                    },
                  )
                else
                  _buildChecklistItems(_scrollController),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  child: widget.note != null
                      ? const Text('Update')
                      : const Text('Create'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      if (widget.note != null && widget.noteKey != null) {
                        _submitForm(
                            false,
                            widget.noteKey!,
                            _destinationController,
                            _noteTitleController,
                            _noteType,
                            _textNoteController,
                            _checkListController);
                      } else {
                        _submitForm(
                            true,
                            -1,
                            _destinationController,
                            _noteTitleController,
                            _noteType,
                            _textNoteController,
                            _checkListController);
                      }
                      formKey.currentState!.reset();
                      if (widget.note != null) {
                        Navigator.pop(context);
                      } else {
                        Provider.of<BottomNavBarProvider>(context,
                                listen: false)
                            .currentIndex
                            .value = 0;
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ListView _buildChecklistItems(parentScrollController) {
    return ListView.builder(
      controller: parentScrollController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: (_checklistItems.length < 2) ? 2 : _checklistItems.length,
      itemBuilder: (context, index) {
        if (index < _checklistItems.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _checkListController[index],
                    decoration: InputDecoration(
                      labelText: 'Item ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please add Item';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _checklistItems[index] = value;
                      });
                    },
                  ),
                ),
                if (index == _checklistItems.length - 1)
                  IconButton(
                    color: Colors.green,
                    splashColor: Colors.green,
                    splashRadius: 26,
                    icon: const Icon(Icons.add),
                    onPressed: _onAddChecklistItem,
                  ),
                if (_checklistItems.length > 2)
                  IconButton(
                    color: Colors.red,
                    splashColor: Colors.red,
                    splashRadius: 26,
                    icon: const Icon(Icons.remove),
                    onPressed: () => _onRemoveChecklistItem(index),
                  ),
              ],
            ),
          );
        }
        return null;
      },
    );
  }

  List<String> extractTextFromControllers(
      List<TextEditingController> controllers) {
    List<String> texts = [];
    for (TextEditingController controller in controllers) {
      texts.add(controller.text.trim());
    }
    return texts;
  }

  void _submitForm(
      bool create,
      dynamic noteKey,
      TextEditingController destination,
      TextEditingController noteTitle,
      String noteType,
      TextEditingController textNote,
      List<TextEditingController> checkList) {
//add data to localstorage
    if (create) {
      _insertNote(destination, noteTitle, noteType, textNote, checkList);
    } else {
      _updateNote(
          noteKey, destination, noteTitle, noteType, textNote, checkList);
    }
  }

  void _insertNote(
      TextEditingController destination,
      TextEditingController noteTitle,
      String noteType,
      TextEditingController textNote,
      List<TextEditingController> checkList) {
    List<String> checkListNote = extractTextFromControllers(checkList);
    if (noteType == 'CheckList' && checkListNote[0].isNotEmpty) {
      insertNote(
        destination: destination.text.toString(),
        notetitle: noteTitle.text.toString(),
        checklist: checkListNote,
      );
    }

    if (noteType == 'Text' && textNote.text.toString().isNotEmpty) {
      insertNote(
          destination: destination.text.toString(),
          notetitle: noteTitle.text.toString(),
          textnote: textNote.text.toString());
    }
  }

  void _updateNote(
    dynamic noteKey,
    TextEditingController destination,
    TextEditingController noteTitle,
    String noteType,
    TextEditingController textNote,
    List<TextEditingController> checkList,
  ) {
    List<String> checkListNote = extractTextFromControllers(checkList);
    if (noteType == 'CheckList' && checkListNote[0].isNotEmpty) {
      updateNote(
        noteKey: noteKey,
        destination: destination.text.toString(),
        notetitle: noteTitle.text.toString(),
        checklist: checkListNote,
        isDelete: false,
        isNotified: false,
      );
    }

    if (noteType == 'Text' && textNote.text.toString().isNotEmpty) {
      updateNote(
        noteKey: noteKey,
        destination: destination.text.toString(),
        notetitle: noteTitle.text.toString(),
        textnote: textNote.text.toString(),
        isDelete: false,
        isNotified: false,
      );
    }
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
                      } else if (predefinedLocations.isNotEmpty &&
                          predefinedLocations.contains(value)) {
                        return 'Location Name already exists';
                      }
                      return null;
                    }),
                const SizedBox(height: 10),
                TextFormField(
                    onTap: () async {
                      String latLng = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const GoogleMapView(),
                        ),
                      );

                      setState(() {
                        coordinatesController.text = latLng;
                      });
                    },
                    readOnly: true,
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
                    setPredefinedLocation().then((value) {
                      _setSelectedLocation(null);
                      Navigator.of(context).pop();
                    });
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
                    formKey.currentState!.reset();
                    setPredefinedLocation().then((value) {
                      _setSelectedLocation(null);
                      Navigator.of(context).pop();
                    });
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
