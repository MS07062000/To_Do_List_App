import 'package:flutter/material.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/Helper/helper.dart';
import 'package:to_do_list_app/HomeScreen/note_content_page.dart';

typedef CardCheckBoxCallBack = void Function(
    bool? checkBoxSelected, int noteIndex, NoteModel note);

typedef NoteEditCallBack = void Function(BuildContext context, NoteModel note);
Widget buildNoteCard(
    BuildContext context,
    CardCheckBoxCallBack checkBoxHandler,
    NoteEditCallBack? noteEditHandler,
    List<bool> selectedItems,
    int noteIndex,
    NoteModel note) {
  void navigateToNoteView(BuildContext context, NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteContentPage(note: note),
      ),
    );
  }

  return GestureDetector(
    onLongPress: () {
      checkBoxHandler(true, noteIndex, note);
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
                  checkBoxHandler(value, noteIndex, note);
                },
              )
            : null,
        title: Text(note.notetitle),
        trailing: noteEditHandler != null
            ? IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  noteEditHandler(context, note);
                },
              )
            : null,
        onTap: () {
          // Handle tap on note card
          navigateToNoteView(context, note);
        },
      ),
    ),
  );
}
