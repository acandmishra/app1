import 'package:app1/utilities/dialogs/generic_dialogs.dart';
import 'package:flutter/material.dart';

Future<bool> showLogOutDialog(BuildContext context){
  return showGenericDialog(
    context: context,
    title: "LogOut",
    content: "Do you want to LogOut",
    optionsBuilder: ()=>{
      "Cancel":false,
      "LogOut":true,
    },
  ).then((value) => value ?? false);
}