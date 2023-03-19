import 'package:app1/constants/routes.dart';
import 'package:app1/services/auth/auth_exceptions.dart';
import 'package:app1/services/auth/auth_service.dart';
import 'package:app1/utilities/show_error_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;


class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title:const Center(child: Text("Register"))),
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
              try {
                final userCredential =  await AuthService.firebase().createUser(
                email: email,
                password: password);
                final user=AuthService.firebase().currentUser;
                AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(verifyEmailRoute);
                devtools.log(userCredential.toString());
              }
              on WeakPasswordAuthException{
                await showErrorDialog(context,"Weak Password");
              }
              on EmailAlredayInUseAuthException{
                await showErrorDialog(context, "Already Registered!");
              }
              on InvalidEmailAuthException{
                await showErrorDialog(context,"Invalid Email ID");
              }
              on GenericAuthException{
                await showErrorDialog(context,"Error Occurred");
              }    
              
            },
            child:const Text("Register"),),

            TextButton(onPressed: (){
              Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text("Already Registered? Login Here"),),
        ],
      ),
    );
  }
}