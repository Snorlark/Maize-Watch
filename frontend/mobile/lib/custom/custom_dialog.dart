import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/services/translation_service.dart';

import 'custom_font.dart';

// For simple dialogs with an 'OK' button
// ignore: non_constant_identifier_names
CustomDialog(BuildContext context, {required String title, required String content}) {
  final TranslationService _translationService = TranslationService();
  
  AlertDialog alertDialog = AlertDialog(
    title: Padding(
      padding: const EdgeInsets.all(15),
      child: CustomFont(text: title, fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
    ),
    content: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CustomFont(text: content, color: Colors.black, fontSize: 16, textAlign: TextAlign.justify),
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
        child: Text(_translationService.translate('okay'))
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
  {required String title, required String content, required Function onYes}
) async {
  final TranslationService _translationService = TranslationService();
  
  AlertDialog alertDialog = AlertDialog(
    title: Padding(
      padding: const EdgeInsets.all(15),
      child: CustomFont(
        text: title, 
        fontWeight: FontWeight.bold, 
        color: Colors.black, 
        fontSize: 20
      ),
    ),
    content: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
       child: CustomFont(text: content, color: Colors.black, fontSize: 16, textAlign: TextAlign.justify),
    ),
    actions: <Widget>[
      OutlinedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        style: OutlinedButton.styleFrom(
           side: BorderSide(width: 1.0, color: MAIZE_PRIMARY),
        ),
        child: CustomFont(text: _translationService.translate('no'), color: MAIZE_PRIMARY,),
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
        child: CustomFont(
          text: _translationService.translate('yes'),
          color: Colors.white,
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