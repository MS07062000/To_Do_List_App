import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef SetStateCallBack = void Function(Function());
typedef NoteTypeChangedCallBack = void Function(String);
typedef DestinationTypeChangedCallBack = void Function(String);
typedef DestinationTapCallBack = void Function();
typedef UserDefinedLocationCallBack = void Function(String);
List<Widget> buildDestinationType(String destinationType,
    DestinationTypeChangedCallBack onDestinationTypeChanged) {
  return [
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
            title: const Text('My Locations'),
            value: 'userDefinedLocation',
            groupValue: destinationType,
            onChanged: ((value) => onDestinationTypeChanged(value!)),
          ),
        ),
        Expanded(
          child: RadioListTile(
            title: const Text('Map'),
            value: 'map',
            groupValue: destinationType,
            onChanged: ((value) => onDestinationTypeChanged(value!)),
          ),
        ),
      ],
    ),
    const SizedBox(height: 10.0),
  ];
}

Widget buildMap(TextEditingController destinationController,
    DestinationTapCallBack onDestinationTap) {
  return TextFormField(
    decoration: const InputDecoration(
      labelText: 'Destination Name',
      suffixIcon: Icon(Icons.map),
      border: OutlineInputBorder(),
    ),
    controller: destinationController,
    onTap: onDestinationTap,
    readOnly: true,
  );
}

Widget buildMyLocation(Map userDefinedLocations, dynamic selectedlocation,
    UserDefinedLocationCallBack onUserDefinedLocation) {
  return DropdownButtonFormField<String>(
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      labelText: 'Select Location',
    ),
    icon: const Icon(Icons.arrow_drop_down),
    menuMaxHeight: 150,
    items: userDefinedLocations.entries.map<DropdownMenuItem<String>>((entry) {
      final String locationName = entry.key.toString();
      final String locationInfo = jsonEncode(entry.value);
      return DropdownMenuItem<String>(
        value: locationInfo,
        child: Text(
          locationName,
          style: const TextStyle(fontSize: 20),
        ),
      );
    }).toList(),
    value: selectedlocation,
    onChanged: (value) => onUserDefinedLocation(value!),
    validator: (value) {
      if (value == null || value.toString().isEmpty) {
        return 'Please select a Location';
      }
      return null;
    },
  );
}

Widget buildNoteTitle(TextEditingController noteTitleController) {
  return TextFormField(
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
      ],
      decoration: const InputDecoration(
        labelText: 'Title',
        border: OutlineInputBorder(),
      ),
      controller: noteTitleController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter title';
        }
        return null;
      });
}

List<Widget> buildNoteType(
    String noteType, NoteTypeChangedCallBack onNoteTypeChanged) {
  return [
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
            groupValue: noteType,
            onChanged: ((value) => onNoteTypeChanged(value!)),
          ),
        ),
        Expanded(
          child: RadioListTile(
            title: const Text('CheckList'),
            value: 'CheckList',
            groupValue: noteType,
            onChanged: ((value) => onNoteTypeChanged(value!)),
          ),
        ),
      ],
    ),
  ];
}

Widget buildTextNote(TextEditingController textNoteController) {
  return TextFormField(
    maxLines: null,
    minLines: 4,
    keyboardType: TextInputType.multiline,
    decoration: const InputDecoration(
      labelText: 'Text Note',
      border: OutlineInputBorder(),
    ),
    controller: textNoteController,
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Please fill text Note';
      }
      return null;
    },
  );
}

ListView buildChecklistItems(
    SetStateCallBack setState,
    ScrollController parentScrollController,
    List<TextEditingController> checkListController,
    List<String> checklistItems) {
  return ListView.builder(
    controller: parentScrollController,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: (checklistItems.length < 2) ? 2 : checklistItems.length,
    itemBuilder: (context, index) {
      if (index < checklistItems.length) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: checkListController[index],
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
                      checklistItems[index] = value;
                    });
                  },
                ),
              ),
              if (index == checklistItems.length - 1)
                IconButton(
                  color: Colors.green,
                  splashColor: Colors.green,
                  splashRadius: 26,
                  icon: const Icon(Icons.add),
                  onPressed: () => onAddChecklistItem(
                    setState,
                    checkListController,
                    checklistItems,
                  ),
                ),
              if (checklistItems.length > 2)
                IconButton(
                  color: Colors.red,
                  splashColor: Colors.red,
                  splashRadius: 26,
                  icon: const Icon(Icons.remove),
                  onPressed: () => onRemoveChecklistItem(
                      setState, checkListController, checklistItems, index),
                ),
            ],
          ),
        );
      }
      return null;
    },
  );
}

void onAddChecklistItem(
  SetStateCallBack setState,
  List<TextEditingController> checkListController,
  List<String> checklistItems,
) {
  setState(() {
    checkListController.add(TextEditingController());
    checklistItems.add('');
  });
}

void onRemoveChecklistItem(
    SetStateCallBack setState,
    List<TextEditingController> checkListController,
    List<String> checklistItems,
    int index) {
  setState(() {
    checkListController.removeAt(index);
    checklistItems.removeAt(index);
  });
}

List<String> extractTextFromControllers(
    List<TextEditingController> controllers) {
  List<String> texts = [];
  for (TextEditingController controller in controllers) {
    texts.add(controller.text.trim());
  }
  return texts;
}
