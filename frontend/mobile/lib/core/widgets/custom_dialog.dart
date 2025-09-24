import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../constants/app_spacing.dart';
import '../theme/colors.dart';

// For simple dialogs with an 'OK' button
// ignore: non_constant_identifier_names
void customDialog(BuildContext context, {required String title, required String content}) {
  
  AlertDialog alertDialog = AlertDialog(
    title: Padding(
      padding: EdgeInsets.all(kAppMediumPadding),
      child: Text( title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20)),
    ),
    content: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text( content, style: TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.justify),
    ),
    actions: <Widget>[
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MAIZE_PRIMARY, 
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(S.of(context).okay)
      ),
    ],
  );
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alertDialog;
    },
  );
}

// For dialogs with Yes/No options
Future<void> customOptionDialog(
  BuildContext context,
  {required String title, required String content, required VoidCallback onYes}
) async {
  
  
  AlertDialog alertDialog = AlertDialog(
    title: Padding(
      padding: EdgeInsets.all(kAppSmallPadding),
      child: Text(
         title, 
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          color: Colors.black, 
          fontSize: 20
        )
      ),
    ),
    content: Padding(
      padding: EdgeInsets.symmetric(horizontal: kAppSmallPadding),
       child: Text( content, style: TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.justify),
    ),
    actions: <Widget>[
      OutlinedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        style: OutlinedButton.styleFrom(
           side: BorderSide(width: 1.0, color: MAIZE_PRIMARY),
        ),
        child: Text( S.of(context).no, style: TextStyle(color: MAIZE_PRIMARY)),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MAIZE_PRIMARY, 
          foregroundColor: Colors.white
        ),
        onPressed: () {
          Navigator.of(context).pop();
          onYes();
        },
        child: Text(
           S.of(context).yes,
          style: TextStyle(color: Colors.white),
        ),
      ),
    ],
  );
 
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return alertDialog;
    },
  );
}