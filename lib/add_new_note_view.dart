// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:to_do_list_app/main.dart';
import 'package:to_do_list_app/note_model.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/osm_map_view.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:to_do_list_app/unknown_map_view.dart';

class AddNewNoteView extends StatefulWidget {
  @override
  _AddNewNoteViewState createState() => _AddNewNoteViewState();
}

class _AddNewNoteViewState extends State<AddNewNoteView> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _textNoteController = TextEditingController();
  final List<TextEditingController> _checkListController = [
    TextEditingController(),
    TextEditingController()
  ];
  String _noteType = 'Text';
  final List<String> _checklistItems = ['', ''];
  final ScrollController _scrollController = ScrollController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _destinationController.dispose();
    _noteTitleController.dispose();
    _textNoteController.dispose();
    super.dispose();
  }

  void _onDestinationTap() async {
    GeoPoint latLng = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OSMMapView(), //UnknownMapView(),
      ),
    );
    setState(() {
      _destinationController.text = '${latLng.latitude}, ${latLng.longitude}';
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
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    suffixIcon: Icon(Icons.map),
                    border: OutlineInputBorder(),
                  ),
                  controller: _destinationController,
                  onTap: _onDestinationTap,
                  readOnly: true,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
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
                  child: const Text('Create'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      _submitForm(_destinationController, _noteTitleController,
                          _textNoteController, _checkListController);
                      formKey.currentState!.reset();
                      //NAVIGATE TO HOMESCREEN IMMEDIATELY
                      Provider.of<BottomNavBarProvider>(context, listen: false)
                          .setCurrentIndex(0);
                      // Perform form submission or any other actions
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
}

List<String> extractTextFromControllers(
    List<TextEditingController> controllers) {
  List<String> texts = [];
  for (TextEditingController controller in controllers) {
    texts.add(controller.text.trim());
  }
  return texts;
}

void _submitForm(destination, noteTitle, textNote, checkList) {
//add data to localstorage
  List<String> checkListNote = extractTextFromControllers(checkList);
  if (checkListNote[0].isNotEmpty) {
    insertNote(
        destination: destination.text.toString(),
        notetitle: noteTitle.text.toString(),
        checklist: checkListNote);
  }

  if (textNote.text.toString().isNotEmpty) {
    insertNote(
        destination: destination.text.toString(),
        notetitle: noteTitle.text.toString(),
        textnote: textNote.text.toString());
  }
}
