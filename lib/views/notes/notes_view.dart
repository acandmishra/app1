import 'package:app1/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import '../../constants/routes.dart';
import '../../enums/menu_actions.dart';
import '../../services/crud/notes_services.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  // below is instance of NotesService so that notes view can use its functionalities
  late final NotesService _notesService;

  String get userEmail => AuthService.firebase().currentUser!.email!;


  // To open the database as we log in into the main ui
  @override
  void initState() {
    _notesService=NotesService();
    // this was needed before:-
    // _notesService.open();
    // nothing is needed now as we have given logic to check if database is open or not and create in negation
    // to function in notesService
    super.initState();
  }

// The dispose function (earlier here as uncommented) is deleted as it was used to close the database upon exiting the newnotes view...
//  but as we converted our notes service into a singleton , it returns the same instance again and again and thereofre,
//  it is imortant to keep it open 

  // @override
  // void dispose() {
  //   _notesService.close();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title:const Text("My Notes"),
      actions:[
        IconButton(
          onPressed:() {
            Navigator.of(context).pushNamed(newNotesRoute);
          },
          icon: const Icon(Icons.add),
          ),
        PopupMenuButton<MenuAction>(onSelected: (value) async {
          switch(value){
            case(MenuAction.logout):
              final loggingOut=await showLogOutDialog(context);
              devtools.log(loggingOut.toString());
              if(loggingOut){
                await AuthService.firebase().logOut();
                Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
              }
          }

            devtools.log(value.toString()); // log is used instead of print command
        }, itemBuilder: (context) {
          return const [PopupMenuItem<MenuAction>(
            value:MenuAction.logout,
            child:Text("Logout"),),];
          
          
        },)
      ]),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder:(context, snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder:(context,snapshot){
                  switch(snapshot.connectionState){
                    // Below is implicit fall through ie. both the below cases will return same widget
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData){
                        final allNotes = snapshot.data;
                        print("this is the info of current note $allNotes");
                        return ListView.builder(
                          itemCount: allNotes!.length,
                          itemBuilder:(context, index) {
                            return ListTile(
                              title: Text(
                                allNotes[index].text,
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor: 1.5,
                              ),
                              
                              
                            );
                          },

                        );
                      }
                      else{
                        return Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 0, 255, 128),));
                      }
                    default:
                      return Center(child: const CircularProgressIndicator());
                  }
                });
            default:
              return Center(child: const CircularProgressIndicator());

          }
        },
      ),
    );
  }
}

  Future<bool>showLogOutDialog(BuildContext context){
  return showDialog<bool>(context: context, builder: (context){
    return AlertDialog(
      title:const Text("Sign Out"),
      content:const Text("Confirm Sign Out?"),
      actions:[
        TextButton(onPressed: (){
          Navigator.of(context).pop(false);
        }, child: const Text("Cancel")),
        TextButton(onPressed: (){
          Navigator.of(context).pop(true);
        }, child: const Text("Sign Out"))
      ]
    );
  }).then((value) => value ?? false);
}