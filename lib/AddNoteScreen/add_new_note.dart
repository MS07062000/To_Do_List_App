import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:to_do_list_app/AddNoteScreen/add_remove_userDefined_location.dart';
import 'package:to_do_list_app/Database/user_defined_location_model.dart';
import 'package:to_do_list_app/Helper/AddEditNoteComponents/addEditNoteComponents.dart';
import 'package:to_do_list_app/Helper/helper.dart';
import 'package:to_do_list_app/Main/bottom_navbar_provider.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/Map/google_map_view.dart';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// import 'package:to_do_list_app/Map/osm_map_view.dart';

class AddNewNoteView extends StatefulWidget {
  const AddNewNoteView({super.key});

  // final NoteModel? note;
  // final dynamic noteKey;
  // const AddNewNoteView({Key? key, this.noteKey, this.note}) : super(key: key);

  @override
  State<AddNewNoteView> createState() => _AddNewNoteViewState();
}

class _AddNewNoteViewState extends State<AddNewNoteView> {
  final formKey = GlobalKey<FormState>();
  String _destinationType = 'map';
  dynamic _locationInfo;
  Map<dynamic, dynamic> userDefinedLocations = {};
  final TextEditingController _destinationController = TextEditingController();
  late String _destinationCoordinates;
  String _noteType = 'Text';
  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _textNoteController = TextEditingController();
  final List<String> _checklistItems = [];
  final List<TextEditingController> _checkListController = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    setUserDefinedLocation();
    _checkListController
        .addAll([TextEditingController(), TextEditingController()]);
    _checklistItems.addAll(['', '']);
    // _setLocationInfo();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _destinationController.dispose();
    _noteTitleController.dispose();
    _textNoteController.dispose();
    super.dispose();
  }

  //getting list of Locations defined by user and assigning it to userDefinedLocations
  Future<void> setUserDefinedLocation() async {
    getUserDefinedLocations().then((locationList) {
      if (locationList.item2) {
        setState(() {
          userDefinedLocations = locationList.item1;
          // log(userDefinedLocations.length.toString());
        });
      }
    });
  }

  void _onDestinationTypeChanged(String destinationType) {
    setState(() {
      _destinationType = destinationType;
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

    Map<String, String?> locationDetails = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GoogleMapView(),
      ),
    );

    setState(() {
      _destinationController.text = locationDetails['destinationName']!;
      _destinationCoordinates = locationDetails['coordinates']!;
    });
  }

  void _onUserDefinedLocation(String locationInfo) async {
    setState(() {
      _locationInfo = locationInfo;
    });
  }

  void _onNoteTypeChanged(String isText) {
    setState(() {
      _noteType = isText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: const Text('Location List'),
          automaticallyImplyLeading: false,
          actions: buildAction()),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (userDefinedLocations.isNotEmpty)
                  ...buildDestinationType(
                      _destinationType, _onDestinationTypeChanged),
                _destinationType == 'map'
                    ? buildMap(_destinationController, _onDestinationTap)
                    : buildMyLocation(userDefinedLocations, _locationInfo,
                        _onUserDefinedLocation),
                const SizedBox(height: 16.0),
                buildNoteTitle(_noteTitleController),
                const SizedBox(height: 16.0),
                ...buildNoteType(_noteType, _onNoteTypeChanged),
                const SizedBox(height: 16.0),
                _noteType == 'Text'
                    ? buildTextNote(_textNoteController)
                    : buildChecklistItems(setState, _scrollController,
                        _checkListController, _checklistItems),
                const SizedBox(height: 16.0),
                buildCreateButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildAction() {
    return [
      const SizedBox(width: 4),
      PopupMenuButton(
        icon: const Icon(Icons.more_vert),
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
          const PopupMenuItem(
            value: 'addLocation',
            child: Text('Add Location'),
          ),
          if (userDefinedLocations.isNotEmpty)
            const PopupMenuItem(
              value: 'removeLocation',
              child: Text('Delete Location'),
            )
        ],
        onSelected: (selectedOption) {
          handleLocationOperation(selectedOption);
        },
      ),
    ];
  }

  void handleLocationOperation(String locationOperation) {
    if (locationOperation == 'addLocation') {
      addNewLocation(context, setState, userDefinedLocations).then((value) {
        // log(value.toString());
        if (value) {
          setUserDefinedLocation();
        }
      });
    }

    if (locationOperation == 'removeLocation') {
      removeLocation(context, setState, userDefinedLocations).then((value) {
        // log(value.toString());
        if (value) {
          setUserDefinedLocation();
        }
      });
    }
  }

  Widget buildCreateButton() {
    return ElevatedButton(
      child: const Text('Create'),
      onPressed: () {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          if (_destinationController.text.isEmpty) {
            // log(json.decode(_locationInfo).toString());
            _destinationController.text =
                json.decode(_locationInfo)['locationName']!;
            _destinationCoordinates =
                json.decode(_locationInfo)['destinationCoordinates']!;
            // log(_destinationCoordinates);
            // log(_destinationController.text.toString());
          }

          _submitForm(
                  _destinationController,
                  _destinationCoordinates,
                  _noteTitleController,
                  _noteType,
                  _textNoteController,
                  _checkListController)
              .then((value) {
            if (value) {
              formKey.currentState!.reset();
              Provider.of<BottomNavBarProvider>(context, listen: false)
                  .currentIndex
                  .value = 0;
            } else {
              dialogOnError(context, "Error in adding new note");
            }
          });
        }
      },
    );
  }

  Future<bool> _submitForm(
      TextEditingController destination,
      String destinationCoordinates,
      TextEditingController noteTitle,
      String noteType,
      TextEditingController textNote,
      List<TextEditingController> checkList) async {
    return await _insertNote(destination, destinationCoordinates, noteTitle,
        noteType, textNote, checkList);
  }

  Future<bool> _insertNote(
      TextEditingController destination,
      String destinationCoordinates,
      TextEditingController noteTitle,
      String noteType,
      TextEditingController textNote,
      List<TextEditingController> checkList) async {
    List<String> checkListNote = extractTextFromControllers(checkList);
    if (noteType == 'CheckList' && checkListNote.isNotEmpty) {
      return await insertNote(
        destination: destination.text.toString(),
        destinationCoordinates: destinationCoordinates,
        notetitle: noteTitle.text.toString(),
        checklist: checkListNote,
      );
    }

    if (noteType == 'Text' && textNote.text.toString().isNotEmpty) {
      return await insertNote(
          destination: destination.text.toString(),
          destinationCoordinates: destinationCoordinates,
          notetitle: noteTitle.text.toString(),
          textnote: textNote.text.toString());
    }
    return false;
  }
}
