import 'package:baller_proj/login.dart';
import 'package:baller_proj/profile.dart';
import 'package:baller_proj/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:baller_proj/splashscreen.dart';
import 'package:baller_proj/home.dart';
import 'package:baller_proj/search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(baller_start());
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class baller_start extends StatefulWidget {
  @override
  State<baller_start> createState() => _baller_startState();
}

class _baller_startState extends State<baller_start> {

  @override



  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      home : splash_screen(),
      //home: LoginPage(),
    );
  }
}
