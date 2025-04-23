
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';
import 'package:maize_watch/custom/constants.dart';

import 'custom_font.dart';

// ignore: non_constant_identifier_names
CustomDialog(BuildContext context, {required title, required content}) {
  
  AlertDialog alertDialog = AlertDialog(
    title: Padding(
      padding: EdgeInsets.all(15),
      child: CustomFont(text: title, fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20,),
    ),
    content: Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomFont(text: content,  color: Colors.black, fontSize: 16, textAlign: TextAlign.justify,),
    ),
    actions: <Widget>[
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: MAIZE_PRIMARY, foregroundColor: Colors.white,),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Okay')
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

customOptionDialog(BuildContext context,
  {required title, required content, required Function onYes}) {
    AlertDialog alertDialog = AlertDialog(
      title: CustomFont(
        text: title,
        fontSize: 30.sp,
      ),
      content: CustomFont(text: content),
      actions: <Widget>[
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const CustomFont(text: 'No'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: MAIZE_PRIMARY, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
              onYes();
            },
          child: const CustomFont(
            text: 'Yes',
            color: Colors.white,
          ),
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
 
  
