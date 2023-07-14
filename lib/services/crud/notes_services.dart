import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'crud_exceptions.dart';





class NotesService{
  Database? _db;
  List <DatabaseNote> _notes = [];

  // Below code line is to convert the NoteService into singleton .... calling to class multiple times will return the same instance 
  static final NotesService _shared =NotesService._sharedInstance(); // 2) the call then comes from 1 to here and private constructor is called
  NotesService._sharedInstance(){
    _notesStreamController=StreamController<List<DatabaseNote>>.broadcast(
      onListen:(){
        _notesStreamController.sink.add(_notes);    
      }
    );
  } // 3) finally the call comes here to create an instance 
  factory NotesService() => _shared; // 1) call to NotesService will first come here and the private instance gets called



  late final _notesStreamController;
  
  
  // the below code will help to retrieve all notes of a user
  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<void> _cacheNotes()async{
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
    
  }

  Future<DatabaseUser> getOrCreateUser({required String email})async{
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUserException {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e){
      rethrow;
    }
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  })async{
    await _ensureDBIsOpen();
    final db=_getDatabaseOrThrow();

    await getNote(id: note.id);

    final updateCount=await db.update(
      noteTable,{
      textColumn:text,
      isSyncedWithCloudColumn:0,
      },
    );
    if (updateCount==0){
      throw CouldNotUpdateNote();
    }
    else{
      final updatedNote= await getNote(id:note.id);
      // The local cache is already being updated above but we do it below too
      _notes.removeWhere((note) => note.id==updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future <Iterable<DatabaseNote>> getAllNotes()async{
    await _ensureDBIsOpen();
    final db=_getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      );
    return notes.map((notesRow) => DatabaseNote.fromRow(notesRow));

  }

  Future<DatabaseNote> getNote({required int id})async{
    await _ensureDBIsOpen();
    final db=_getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit:1,
      where:'id = ?',
      whereArgs:[id],
      );
    if (notes.isEmpty){
      throw CouldNotFindNoteException();
    }
    final note= DatabaseNote.fromRow(notes.first);
    //  We are updating local cache to ensure its relevant with any changes made so far
    _notes.removeWhere((note)=>note.id==id);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }


  Future<int> deleteAllNotes() async{
    await _ensureDBIsOpen();
    final db=_getDatabaseOrThrow();
    final rowsdeleted=await db.delete(noteTable);
    _notes=[];
    _notesStreamController.add(_notes);
    return rowsdeleted;
    }



  Future<void> deleteNote({required int id})async{
    await _ensureDBIsOpen();
    final db=_getDatabaseOrThrow();
    final deleteCount=await db.delete(
      noteTable,
      where:'id = ?',
      whereArgs:[id],
    );
    if(deleteCount==0){
      throw CouldNotDeleteNoteException();
    }
    else{
      _notes.removeWhere((note) => note.id==id);
      _notesStreamController.add(_notes);                
    }
    
  }


  Future<DatabaseNote> createNote({required DatabaseUser owner})async {
    await _ensureDBIsOpen();
    final db=_getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    // using the equality operator we made to check if both users have everything same or not, ie. it exists already or not!
    if (dbUser != owner){
    throw CouldNotFindUserException();
    }
    const text="";
    final notesId=await db.insert(noteTable,{
      userIdColumn:owner.id,
      textColumn:text,
      isSyncedWithCloudColumn:1,
    });
    final note=DatabaseNote(
      id:notesId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
      );
      _notes.add(note);
      _notesStreamController.add(_notes); 
      return note;

  }

  Future<DatabaseUser> getUser({required email}) async{
    await _ensureDBIsOpen();
    final db=_getDatabaseOrThrow();
    final result=await db.query(
      userTable,
      limit:1,
      where:'email = ?',
      whereArgs:[email.toLowerCase()],
      );
    if(result.isEmpty){
      throw CouldNotFindUserException();
    }
    return DatabaseUser.fromRow(result.first);
  }


  Future<DatabaseUser>createUser({required String email})async{
    await _ensureDBIsOpen();
    final db=_getDatabaseOrThrow();
    // first we will check if user already exists or not by using below function which returns a list   
    final result=await db.query(
      userTable,
      limit:1,
      where:'email = ?',
      whereArgs: [email.toLowerCase()],
      );
    if(result.isNotEmpty){
      throw UserAlreadyExistsException();
    }
    final userId =await db.insert(
      userTable,
      {
        emailColumn:email.toLowerCase(),
      });

    return DatabaseUser(
      id: userId,
      email: email,
      );
  }



  Future<void> deleteUser({required String email})async{
    await _ensureDBIsOpen();
    final db=_getDatabaseOrThrow();
    final deleteCount=await db.delete(
      userTable,
      where:'email = ?',
      whereArgs:[email.toLowerCase()],
    );
    if(deleteCount!=1){
      throw CouldNotDeleteUserException();
    }

  }

  Database _getDatabaseOrThrow(){
    final db=_db;
    if(db==null){
      throw DatabaseIsNotOpenException();
    }
    else{
      return db;
    }
  }

  Future<void> close()async{
    final db=_db;
    if(db==null){
      throw DatabaseIsNotOpenException();
    }
    else{
      await db.close();
      _db=null;
    }
  }

Future<void> _ensureDBIsOpen()async{
  try{
    await open();
  } on DatabaseAlreadyOpenException {
    // 
  }
}

    Future<void> open()async{
      if(_db!=null){
        throw DatabaseAlreadyOpenException();
      }
      try{
        final docsPath = await getApplicationDocumentsDirectory();
        final dbPath=join(docsPath.path,dbName);
        //joining name of db to the path of docs folder of app1
        final db=await openDatabase(dbPath);
        _db=db;
        

        await db.execute(createUserTable);

        await db.execute(createNotesTable);

        // Caching all notes from database
        await _cacheNotes();
        
      } on MissingPlatformDirectoryException{
        throw UnableToGetDocumentsDirectory();
      } 
    }
  }

// Class to represent User in our database
@immutable
class DatabaseUser{
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  // Factory constructor to set values for id and email by taking respective values from the databse 
  DatabaseUser.fromRow(Map<String,Object?>map):
    id = map[idColumn] as int,
    email = map[emailColumn] as String;

  // An override function to return the string to be able to know who the user is
  @override
  String toString()=>"Person,id=$id and email =$email";

  @override bool operator == (covariant DatabaseUser other) => id ==other.id;
  
  @override
  int get hashCode => id.hashCode;
  
}

// Class to represent notes of users
class DatabaseNote{
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
    });
  DatabaseNote.fromRow(Map<String,Object?>map):
    id = map[idColumn] as int,
    userId = map[userIdColumn] as int,
    text = map[textColumn] as String,
    isSyncedWithCloud=(map[isSyncedWithCloudColumn] as int)==1 ? true :false;

  @override 
  String toString()=> "Id=$id,user=$userId,isSyncedWithCloud=$isSyncedWithCloud";

  @override bool operator == (covariant DatabaseNote other) => id ==other.id;
  
  @override
  int get hashCode => id.hashCode;

}




const dbName="Notes.db";
const noteTable="notes";
const userTable="users";
const idColumn="id";
const emailColumn="email";
const userIdColumn="user_id";
const textColumn="text";
const isSyncedWithCloudColumn="is_synced_with_server";

const createUserTable ="""CREATE TABLE IF NOT EXISTS "users" (
	"id"	INTEGER NOT NULL UNIQUE,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
)""";

const createNotesTable ="""CREATE TABLE IF NOT EXISTS "notes" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_synced_with_server"	INTEGER NOT NULL DEFAULT 0,
	FOREIGN KEY("user_id") REFERENCES "user"("id"),
	PRIMARY KEY("id" AUTOINCREMENT)
)""";