import 'package:app1/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import '../constants/routes.dart';
import '../enums/menu_actions.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title:const Text("My Notes"),
      actions:[
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