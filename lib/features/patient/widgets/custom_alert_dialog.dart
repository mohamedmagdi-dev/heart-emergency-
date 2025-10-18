import 'package:flutter/material.dart';

void showProgressIndactor(context){
  AlertDialog alertDialog=AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Center(
      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),),
    ),
  );
  showDialog(
      barrierColor: Colors.white.withValues(alpha: 0),
      barrierDismissible: false,
      context: context, builder: (context){
    return alertDialog;
  });
}