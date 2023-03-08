import 'package:app1/firebase_options.dart';
import 'package:app1/views/register_view.dart';
import 'package:app1/views/login_view.dart';
import 'package:app1/views/verify_email_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


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
                if (user?.emailVerified ?? false) {
                  print("you are a verified user");
                  return const Text("Done");}
                else{
                  print(user);
                  print("user printed");
                  return const LoginView();
                  return const VerifyEmailView();
                } 
              
            default:
              return const Text("Loading..."); 
          }
          
        }
      );
  }
}


