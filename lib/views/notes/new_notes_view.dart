import 'package:app1/services/auth/auth_service.dart';
import 'package:app1/services/crud/notes_services.dart';
import 'package:flutter/material.dart';

class NewNotesView extends StatefulWidget {
  const NewNotesView({super.key});

  @override
  State<NewNotesView> createState() => _NewNotesViewState();
}

class _NewNotesViewState extends State<NewNotesView> {

// Below 2 values are kept on hold ie. they will not be recreated again and again while we change our code or else we will have many new notes unnecessarily
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;


  // Below is the text listener that will be used in process to update the notes as the text s being changed in the note
  void _textControllerListener() async {
    final note = _note;
    if(note == null){
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
      note: note,
      text: text
    );
  }


void _setupTextControllerListener(){
  _textController.removeListener(_textControllerListener);
  _textController.addListener(_textControllerListener);
}



  // The below function is to create new note
  Future<DatabaseNote> createNewNote() async{
    final existingNote = _note;
    if(existingNote != null){
      return existingNote;
    }
    final email = AuthService.firebase().currentUser!.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }


  
  // The below function is to delete the note if its created and empty upon leaving the new note page
  void _deleteNoteIfTextIsEmpty(){
    final note = _note;
    if (_textController.text.isEmpty && note !=null){
      _notesService.deleteNote(id: note.id);
      print("Note Deleted");
    }
  }

  void _saveNoteIfTextNotEmpty()async{
    final note =_note;
    final text =_textController.text;
    if(text.isNotEmpty && note!=null){
      await _notesService.updateNote(
        note: note,
        text: text
      );
    print("Note Updated");
    }
  }


@override
  void initState() {
    _notesService = NotesService();
    print("DB opened");
    _textController = TextEditingController();
    super.initState();
  }



@override
  void dispose() {
    _saveNoteIfTextNotEmpty();
    _deleteNoteIfTextIsEmpty();
    _textController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
      ),
      body: FutureBuilder (
        future: createNewNote(),
        builder:(context,snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.done:
              _note=snapshot.data;
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                showCursor: true,
                autocorrect: true,
                decoration:const InputDecoration(
                  hintText: "Write here",
                )
                );
            default:
            return const CircularProgressIndicator(color: Colors.lightGreen,);
          }
        }
        ),
    );
  }
}