import 'package:flutter/material.dart';
import 'package:to_do_list_app/Database/note_model.dart';

class NoteContentPage extends StatelessWidget {
  final NoteModel note;
  NoteContentPage({super.key, required this.note});
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(note.notetitle),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildNoteContent(_scrollController),
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

  Widget buildNoteContent(parentScrollController) {
    if (note.textnote != null) {
      // Single string note
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(note.textnote!),
      );
    } else if (note.checklist != null) {
      // Array of notes
      return ListView.builder(
        controller: parentScrollController,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: note.checklist!.length,
        itemBuilder: (context, index) {
          return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.purple, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                title: Text(note.checklist![index]),
              ));
        },
      );
    } else {
      return const Text('Note content not available');
    }
  }
}
