import 'package:app1/constants/routes.dart';
import 'package:app1/services/auth/auth_service.dart';
import 'package:app1/views/notes/new_notes_view.dart';
import 'package:app1/views/notes/notes_view.dart';
import 'package:app1/views/register_view.dart';
import 'package:app1/views/login_view.dart';
import 'package:app1/views/verify_email_view.dart';
import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        dialogBackgroundColor: Colors.blueGrey,
        scaffoldBackgroundColor: Color.fromARGB(253, 255, 255, 255),
      ),
      home: const HomePage(),
      routes:{
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute:(context) => const VerifyEmailView(),
        newNotesRoute:(context) => const NewNotesView(),
      }
    ));
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

 @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:AuthService.firebase().initialise(),
        builder: (context,snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
                final user = AuthService.firebase().currentUser;
                
                if(user!=null){
                  if(user.isEmailVerified){
                    return const NotesView();

                  }
                  else{
                    
                    return const VerifyEmailView();
                  }
                } 
                else{
                  return const RegisterView();
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



// New Stateful Widget :-NotesView


