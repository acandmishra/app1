import 'package:app1/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState(); // written to convert HomePage to stateful widget as we wanr to work with the mutable data in the text field
}



class _LoginViewState extends State<LoginView> {

 late final TextEditingController _email;
   late final TextEditingController _password;

   @override
  void initState() {    // this function is used here to assign the values to the late variables
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {    // this function is used to dispose the late variables once the root widget ie. the HomePage dies
    _email.dispose();
    _password.dispose(); 
    super.dispose();
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title:const Center(child:Text("Login"))),
      body: FutureBuilder(
        future:Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,),
        builder: (context,snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
            return Column(
            children: [
              TextField(
                controller:_email,
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: false,
                autocorrect: false,
                decoration:const InputDecoration(hintText: "Email->"),
              ),
              TextField(
                controller:_password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration:const InputDecoration(hintText: "Password->"),
              ),
              TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try {
                    final userCredential =  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password);
                  print(userCredential);
                  } 
                  on FirebaseAuthException catch (e){ //used to catch specified exception
                    print("Failed to authenticate!");
                    print(e.code);  //to get the error code ie. specific error inside the FirebasAuthException
                  }
                  catch (e) {
                    print("Invalid User");
                    print(e); 
                    print(e.runtimeType); 
                  }
                  
                  
                },
                child:const Text("Login"),),
            ],
          );
              
            
            default:
            return const Text("Loading..."); 
          }
          
        }
      )
    );
  }
   

 
}