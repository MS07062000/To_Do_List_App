import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:to_do_list_app/main.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/Map/osm_map_view.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:to_do_list_app/Map/unknown_map_view.dart';

class AddNewNoteView extends StatefulWidget {
  final NoteModel? note;
  final dynamic noteKey;
  const AddNewNoteView({Key? key, this.noteKey, this.note}) : super(key: key);

  @override
  State<AddNewNoteView> createState() => _AddNewNoteViewState();
}

class _AddNewNoteViewState extends State<AddNewNoteView> {
  final formKey = GlobalKey<FormState>();
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
    if (widget.note != null) {
      // Initialize the form fields with the values from the existing note
      _destinationController.text = widget.note!.destination;
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

  void _onDestinationTap() async {
    GeoPoint latLng = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OSMMapView(), //UnknownMapView(),
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
                            .setCurrentIndex(0);
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
}
