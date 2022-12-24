import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:baller_proj/splashscreen.dart';
import 'package:baller_proj/search.dart';
import 'package:baller_proj/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class homepage extends StatefulWidget {
  const homepage({Key? key, required this.person}) : super(key: key);
  final Person person;

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 55, 0, 0),
                    child: Text(
                      "baller.",
                      style: TextStyle(
                        fontFamily: 'FuturaBold',
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 58, 15, 0),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color:Colors.white,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(
            color: Colors.grey,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'FuturaBold',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Divider(
                  color: Colors.grey,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8,8,8,12),
                      child: Icon(
                        Icons.home_rounded,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                        onTap: (){
                          Navigator.push(context, PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) => searchpage(person: widget.person),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),);
                        },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8,8,8,12),
                        child: Icon(
                          Icons.search_rounded,
                          size: 35,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) => profilepage(person: widget.person),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8,8,8,12),
                        child: Icon(
                          Icons.person,
                          size: 35,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
