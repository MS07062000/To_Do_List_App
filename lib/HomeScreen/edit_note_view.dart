import 'package:flutter/material.dart';
import 'package:to_do_list_app/AddNoteScreen/add_new_note_view.dart';

import '../Database/note_model.dart';

class EditNoteView extends StatelessWidget {
  final NoteModel note;
  final int noteIndex;
  const EditNoteView({super.key, required this.noteIndex, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(note.notetitle),
        ),
        body: AddNewNoteView(noteIndex: noteIndex, note: note));
  }
}
