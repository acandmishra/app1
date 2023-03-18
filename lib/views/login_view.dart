import 'package:app1/constants/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import '../utilities/show_error_dialog.dart';



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
      appBar:AppBar(title:const Center(child:  Text("Login")),),
       body: Column(
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
              final user =FirebaseAuth.instance.currentUser;
              
              try {
              final userCredential =  await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password);
            devtools.log(userCredential.toString());
            if(user?.emailVerified??false){
            Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false,);
            }
            else{
              Navigator.of(context).pushNamed(verifyEmailRoute);
            }
            } 
            on FirebaseAuthException catch (e) { //used to catch specified exception
              if(e.code=="wrong-password"){
                await showErrorDialog(context,"Wrong Password");
              devtools.log("Failed to authenticate!");
              devtools.log(e.code.toString());}
                //to get the error code ie. specific error inside the FirebasAuthException
              else if (e.code=="user-not-found"){
                await showErrorDialog(context,"User Not Found");   
              }
              else{
                await showErrorDialog(context, "Error: ${e.code}");
              }
            
            }
            catch (e) {
              await showErrorDialog(context, e.toString());
            }
              
              
              
              
              
            },
            child:const Text("Login"),),
            TextButton(onPressed:() {
            Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
          },
           child: const Text("Register Here"),)
        ],
         ),
     );
  }
   
}


