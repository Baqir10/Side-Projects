import 'dart:io';

import 'package:baller_proj/register.dart';
import 'package:baller_proj/widgets.dart';
import 'package:baller_proj/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:baller_proj/home.dart';
import 'package:baller_proj/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baller_proj/profileedit.dart';
import 'package:baller_proj/login.dart';
import 'package:baller_proj/uploaddp.dart';

class settingspage extends StatefulWidget {
  final Person person;
  const settingspage({Key? key, required this.person}) : super(key: key);

  @override
  State<settingspage> createState() => _settingspageState();
}

class _settingspageState extends State<settingspage> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                uploaddppage(person: widget.person),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Align(alignment: Alignment.center,
                        child: Image.file(
                          File(widget.person.dpPath),
                          height: 100,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                uploaddppage(person: widget.person),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Align(alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(80,0,0,0),
                          child: Icon(
                            Icons.photo_camera,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                profileEditPage(person: widget.person),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Text(
                        "profile",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'FuturaBold',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        logout();
                      },
                      child: Text(
                        "logout",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'FuturaBold',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  logout() async {
    setState(() {
      isLoading = true;
    });
    try {
      SharedPreferences sf = await SharedPreferences.getInstance();
      await sf.setString('firstName', "");
      widget.person.firstName = "";
      await sf.setString('lastName', "");
      widget.person.lastName = "";
      await sf.setString('email', "");
      widget.person.dpPath = "";
      await sf.setString('dpPath', "");
      await sf.setString('userLoggedInKey', "LoggedOut");
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => loginpage()),
          (route) => false);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      return null;
    }
  }
}
