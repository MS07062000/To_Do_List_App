import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:to_do_list_app/Database/user_defined_location_model.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/Helper/AddEditNoteComponents/addEditNoteComponents.dart';
import 'package:to_do_list_app/Helper/helper.dart';
import 'package:to_do_list_app/Map/google_map_view.dart';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// import 'package:to_do_list_app/Map/osm_map_view.dart';

class EditNote extends StatefulWidget {
  final NoteModel note;
  final dynamic noteKey;
  const EditNote({Key? key, required this.noteKey, required this.note})
      : super(key: key);

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  final formKey = GlobalKey<FormState>();
  String _destinationType = 'userDefinedLocation';
  dynamic _locationInfo;
  late String _destinationCoordinates;
  Map<dynamic, dynamic> userDefinedLocations = {};
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
    _setUserDefinedLocation();
    // Initialize the form fields with the values from the existing note
    _destinationType = 'map';
    _destinationController.text = widget.note.destination;
    _destinationCoordinates = widget.note.destinationCoordinates;
    _setLocationInfo(widget.note.destinationCoordinates);

    _noteTitleController.text = widget.note.notetitle;
    if (widget.note.textnote != null && widget.note.textnote!.isNotEmpty) {
      _textNoteController.text = widget.note.textnote!;
    }

    if (widget.note.checklist != null && widget.note.checklist!.isNotEmpty) {
      _checklistItems.addAll(widget.note.checklist!);
      _checkListController.addAll(List.generate(
        widget.note.checklist!.length,
        (_) => TextEditingController(),
      ));
      for (int i = 0; i < widget.note.checklist!.length; i++) {
        _checkListController[i].text = widget.note.checklist![i];
      }
      _noteType = 'CheckList';
    } else {
      _checkListController
          .addAll([TextEditingController(), TextEditingController()]);
      _checklistItems.addAll(['', '']);
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

  Future<void> _setUserDefinedLocation() async {
    await getUserDefinedLocations().then((locationList) {
      if (locationList.item2) {
        setState(() {
          userDefinedLocations = locationList.item1;
        });
      }
    });
  }

  void _setLocationInfo(String coordinates) async {
    if (coordinates.isNotEmpty) {
      getLocationInfo(coordinates).then((locationDetails) {
        if (locationDetails.item1.isNotEmpty && locationDetails.item2) {
          setState(() {
            _locationInfo = jsonEncode(locationDetails.item1);
            _destinationController.text = '';
            _destinationType = 'userDefinedLocation';
          });
        } else {
          setState(() {
            _destinationType = 'map';
          });
        }
      });
    }
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

    // log(_destinationCoordinates);
    // log(_destinationCoordinates);
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
                const SizedBox(height: 10.0),
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
                buildUpdateButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildUpdateButton() {
    return ElevatedButton(
      child: const Text('Update'),
      onPressed: () {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          if (_destinationController.text.isEmpty) {
            _destinationController.text =
                json.decode(_locationInfo)['locationName']!;
            _destinationCoordinates =
                json.decode(_locationInfo)['destinationCoordinates']!;
          }

          _submitForm(
                  widget.noteKey,
                  _destinationController,
                  _destinationCoordinates,
                  _noteTitleController,
                  _noteType,
                  _textNoteController,
                  _checkListController)
              .then((result) {
            if (result) {
              formKey.currentState!.reset();
              Navigator.pop(context);
            } else {
              dialogOnError(context, "Error in Updating Notes");
            }
          });
        }
      },
    );
  }

  Future<bool> _submitForm(
      dynamic noteKey,
      TextEditingController destination,
      String destinationCoordinates,
      TextEditingController noteTitle,
      String noteType,
      TextEditingController textNote,
      List<TextEditingController> checkList) async {
    return await _updateNote(noteKey, destination, destinationCoordinates,
        noteTitle, noteType, textNote, checkList);
  }

  Future<bool> _updateNote(
    dynamic noteKey,
    TextEditingController destination,
    String destinationCoordinates,
    TextEditingController noteTitle,
    String noteType,
    TextEditingController textNote,
    List<TextEditingController> checkList,
  ) async {
    List<String> checkListNote = extractTextFromControllers(checkList);
    if (noteType == 'CheckList' && checkListNote.isNotEmpty) {
      return await updateNote(
        noteKey: noteKey,
        destination: destination.text.toString(),
        destinationCoordinates: destinationCoordinates,
        notetitle: noteTitle.text.toString(),
        checklist: checkListNote,
        isDelete: false,
        isNotified: false,
      );
    }

    if (noteType == 'Text' && textNote.text.toString().isNotEmpty) {
      return await updateNote(
        noteKey: noteKey,
        destination: destination.text.toString(),
        destinationCoordinates: destinationCoordinates,
        notetitle: noteTitle.text.toString(),
        textnote: textNote.text.toString(),
        isDelete: false,
        isNotified: false,
      );
    }

    return false;
  }
}
