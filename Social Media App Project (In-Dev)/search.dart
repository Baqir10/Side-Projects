import 'package:baller_proj/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:baller_proj/home.dart';
import 'package:baller_proj/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class searchpage extends StatefulWidget {
  final Person person;
  const searchpage({Key? key, required this.person}) : super(key: key);

  @override
  State<searchpage> createState() => _searchpageState();
}

class _searchpageState extends State<searchpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'search',
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
                    GestureDetector(
                      onTap: (){
                        Navigator.pushAndRemoveUntil(context,  PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) => homepage(person: widget.person),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ), (route) => false);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8,8,8,12),
                        child: Icon(
                          Icons.home_rounded,
                          size: 35,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8,8,8,12),
                      child: GestureDetector(
                        onTap: () {
                          //Navigator.pushNamed(context, '/search');
                        },
                        child: Icon(
                          Icons.search_rounded,
                          size: 35,
                          color: Colors.white,
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
