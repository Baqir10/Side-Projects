import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:baller_proj/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baller_proj/register.dart';
import 'package:baller_proj/login.dart';

class Person {
  String firebaseKey = "";
  String firstName = "";
  String lastName = "";
  String pp = "";
  String userName = "";
  String email = "";
  String pos = "";
  String dpPath = "";
  int goals = 0;
  int assists = 0;
}

class splash_screen extends StatefulWidget {
  const splash_screen({Key? key}) : super(key: key);

  @override
  State<splash_screen> createState() => _splash_screenState();
}

class _splash_screenState extends State<splash_screen> {

  late VideoPlayerController _controller;

  bool signIn = false;
  Person person = Person();

  isLoggedIn() async{
    SharedPreferences sf = await SharedPreferences.getInstance();
    if(sf.getString('userLoggedInKey') == 'SignedIn'){
      setState(() {
        signIn = true;
        person.firebaseKey = sf.getString('firebaseKey')!;
        person.firstName = sf.getString('firstName')!;
        person.lastName = sf.getString('lastName')!;
        person.userName = sf.getString('userName')!;
        person.email = sf.getString('email')!;
        person.pos = sf.getString('pos')!;
        person.goals = sf.getInt('goals')!;
        person.assists = sf.getInt('assists')!;
        person.dpPath = sf.getString('dpPath')!;
      });
    }
  }

  @override
  void initState(){
    isLoggedIn();
    super.initState();

    _controller = VideoPlayerController.asset(
        'assets/Logo_no_transparency.mp4',
    )

    ..initialize().then((_) {
      setState(() {

      });
    })
    ..setVolume(0.0);

    _playVideo();
  }

  void _playVideo() async{
    _controller.play();

    await Future.delayed(const Duration(milliseconds: 2500));
    if (signIn == true){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) => homepage(
            person : person,
          )), (route) => false);
    }
    else{
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) => loginpage(
          )), (route) => false);
    }
  }

  @override
  void dispose(){
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
            child: Padding(
              padding: const EdgeInsets.all(100.0),
              child: VideoPlayer(
                _controller,
              ),
            )
          )
              : Container(),
        )
    );
  }
}
