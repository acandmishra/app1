import 'package:app1/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:AppBar(title:const Text("Email Verification"),),
      body: Column(children: [
          const Text("Email verification sent on registered id"),
          const Text("Haven't received yet , click below"),
          TextButton(onPressed: () {
            AuthService.firebase().currentUser;
          }, child: const Text("Send Email Verification")),
        ]),
    );
  }
}