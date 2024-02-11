import 'package:app1/utilities/dialogs/generic_dialogs.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
){
  return showGenericDialog(
    context: context,
    title: "Error Occured",
    content: text,
    optionsBuilder: ()=>{
      "OK":null,
    }, // Map<String,dynamic?>
  );
}