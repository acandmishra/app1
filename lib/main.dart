import 'package:app1/firebase_options.dart';
import 'package:app1/views/register_view.dart';
import 'package:app1/views/login_view.dart';
import 'package:app1/views/verify_email_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes:{
        "/login/": (context) => const LoginView(),
        "/register/": (context) => const RegisterView(),
        "/notes/": (context) => const NotesView(),
      }
    ));
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

 @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,),
        builder: (context,snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
                final user = FirebaseAuth.instance.currentUser;
                if(user!=null){
                  if(user.emailVerified){
                    return const NotesView();

                  }
                  else{
                    return const VerifyEmailView();
                  }
                }
                else{
                  return const LoginView();
                }
                
                // if (user?.emailVerified ?? false) {
                //   print("you are a verified user");
                //   return const Text("Done");}
                // else{
                //   print(user);
                //   print("user printed");
                //   return const LoginView();
                //   return const VerifyEmailView();
                // } 
              
            default:
              return const Text("Loading..."); 
          }
          
        }
      );
  }
}

enum MenuAction{logout}

// New Stateful Widget :-NotesView

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
              final LoggingOut=await showLogOutDialog(context);
              devtools.log(LoggingOut.toString());
              if(LoggingOut){
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil("/login/", (route) => false);
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
