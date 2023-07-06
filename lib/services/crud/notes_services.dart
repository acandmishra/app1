import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'crud_exceptions.dart';





class NotesService{
  Database? _db;

Future<DatabaseNote> updateNote({
  required DatabaseNote note,
  required String text,
})async{
  final db=_getDatabaseOrThrow();

  await getNote(id: note.id);

  final updateCount=await db.update(noteTable,{
    textColumn:text,
    isSyncedWithCloudColumn:0,
  });
  if (updateCount==0){
    throw CouldNotUpdateNote();
  }
  else{
    return await getNote(id:note.id);
  }
}

Future <Iterable<DatabaseNote>> getAllNotes()async{
  final db=_getDatabaseOrThrow();
  final notes = await db.query(
    noteTable,
    );
  return notes.map((notesRow) => DatabaseNote.fromRow(notesRow));

}

Future<DatabaseNote> getNote({required int id})async{
  final db=_getDatabaseOrThrow();
  final notes = await db.query(
    noteTable,
    limit:1,
    where:"note =?",
    whereArgs:[id],
    );
  if (notes.isEmpty){
    throw CouldNotFindNoteException();
  }
  return DatabaseNote.fromRow(notes.first);
}

Future<int> deleteAllNotes() async{
  final db=_getDatabaseOrThrow();
  final rows=await db.delete(noteTable);
  return rows;
  }

Future<void> deleteNote({required int id})async{
  final db=_getDatabaseOrThrow();
  final deleteCount=await db.delete(
    noteTable,
    where:"id=?",
    whereArgs:[id],
  );
  if(deleteCount==0){
    throw CouldNotDeleteNoteException();
  }

}

Future<DatabaseNote> createNote({required DatabaseUser owner})async {
  final db=_getDatabaseOrThrow();
  final dbUser = await getUser(email: owner.email);
  // using the equality operator we made to check if both users have everything same or not, ie. it exists already or not!
  if (dbUser !=owner){
  throw CouldNotFindUserException();
  }
  const text="";
  final notesId=await db.insert(noteTable,{
    userIdColumn:owner.id,
    textColumn:text,
    isSyncedWithCloudColumn:1,
  });
  return DatabaseNote(
    id:notesId,
    userId: owner.id,
    text: text,
    isSyncedWithCloud: true,
    );

}

Future<DatabaseUser> getUser({required email}) async{
  final db=_getDatabaseOrThrow();
   final result=await db.query(
    userTable,
    limit:1,
    where:"email=?",
    whereArgs:[email.toLowerCase()],
    );
  if(result.isEmpty){
    throw CouldNotFindUserException();
  }
  return DatabaseUser.fromRow(result.first);
}

Future<DatabaseUser>createUser({required String email})async{
  final db=_getDatabaseOrThrow();
  // first we will check if user already exists or not by using below function which returns a list   
  final result=await db.query(
    userTable,
    limit:1,
    where:"email=?",
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
  final db=_getDatabaseOrThrow();
  final deleteCount=await db.delete(
    userTable,
    where:"email=?",
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

  Future<void> open()async{
    if(_db!=null){
      throw DatabaseAlreadyOpenException();
    }
    try{
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath=join(docsPath.path,dbName); //joining name of db to the path of docs folder of app1
      final db=await openDatabase(dbPath);
      _db=db;

      await db.execute(createUserTable);

      await db.execute(createNotesTable);
      
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




const dbName="notes.db";
const noteTable="note";
const userTable="user";
const idColumn="id";
const emailColumn="email";
const userIdColumn="user_id";
const textColumn="text";
const isSyncedWithCloudColumn="is_synced_with_server";
const createUserTable = """ CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL UNIQUE,
	"email id"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);""";
const createNotesTable =""" CREATE TABLE IF NOT EXISTS "notes" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_synced_with_server"	INTEGER NOT NULL DEFAULT 0,
	FOREIGN KEY("user_id") REFERENCES "user"("id"),
	PRIMARY KEY("id" AUTOINCREMENT)
);""";