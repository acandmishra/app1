import 'package:app1/services/crud/notes_services.dart';
import 'package:app1/utilities/dialogs/delete_dialogs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


// Making Alias for our deletion function
typedef DeleteNoteCallBack = void Function(DatabaseNote note);


class NotesListView extends StatelessWidget {

  final List<DatabaseNote> notes;
  final DeleteNoteCallBack onDeleteNote;

  const NotesListView({super.key, required this.notes, required this.onDeleteNote});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: notes.length,
        itemBuilder:(context, index) {
          final note=notes[index];
          return ListTile(
            title: Text(
              note.text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textScaleFactor: 1.5,
            ),
            textColor: const Color.fromARGB(255, 233, 30, 125),
            trailing:IconButton(
              onPressed: () async{
                final shouldDelete = await showDeleteDialog(context);
                if(shouldDelete){
                  onDeleteNote(note);
                }
              },
              icon: const Icon(Icons.delete),) ,
                                          
          );
        },

    );
  }
}