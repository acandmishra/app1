import 'package:app1/utilities/dialogs/generic_dialogs.dart';
import 'package:flutter/material.dart';

Future<bool> showDeleteDialog(BuildContext context){
  return showGenericDialog(
    context: context,
    title: "Delete",
    content: "Confirm deletion?",
    optionsBuilder: ()=>{
      "Cancel":false,
      "Yes":true,
    },
  ).then((value) => value ?? false);
}