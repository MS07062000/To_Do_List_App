import 'package:flutter/material.dart';
import 'package:to_do_list_app/EditNoteScreen/edit_note.dart';
import '../Database/note_model.dart';

class EditNoteView extends StatelessWidget {
  final NoteModel note;
  final int noteKey;
  const EditNoteView({super.key, required this.noteKey, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(note.notetitle),
        ),
        body: EditNote(noteKey: noteKey, note: note));
  }
}
