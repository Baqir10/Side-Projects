import 'package:flutter/material.dart';

void showSnackbar(context, message, color){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          //fontFamily: 'FuturaBold',
        ),
      ),
    backgroundColor: color,
    duration: const Duration(seconds: 3),
    action: SnackBarAction(
      label: "Dismiss",
      onPressed: (){

      },
      textColor: Colors.white,
    ) ,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  )
  );
}

