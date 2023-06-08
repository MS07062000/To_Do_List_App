// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:to_do_list_app/note_model.dart';

class NoteContentPage extends StatelessWidget {
  final NoteModel note;

  const NoteContentPage({required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(note.notetitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: buildNoteContent(),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNoteContent() {
    if (note.textnote != null) {
      // Single string note
      return Text(note.textnote!);
    } else if (note.checklist != null) {
      // Array of notes
      return ListView.builder(
        itemCount: note.checklist!.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(note.checklist![index]),
          );
        },
      );
    } else {
      return const Text('Note content not available');
    }
  }
}
