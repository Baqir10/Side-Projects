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

class loginpage extends StatefulWidget {
  const loginpage({Key? key}) : super(key: key);

  @override
  State<loginpage> createState() => _loginpageState();
}


class _loginpageState extends State<loginpage> {
  final Person person = Person();
  String userName = "";
  String password = "";
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  bool visible = true;
  //AuthService authService = AuthService();


  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(
          child: CircularProgressIndicator(
              color: Colors.white))
          : SingleChildScrollView(
        //physics: ClampingScrollPhysics(parent: NeverScrollableScrollPhysics()),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height:150),

              Image.asset(
                'assets/LOGO_IMAGE.png',
                height: 150,
              ),

              SizedBox(height:80),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration: textInputDecoration.copyWith(
                    labelText: "Username",
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  onChanged: (val){
                    setState(() {
                      userName = val;
                      //debugPrint(email);
                    });
                  },

                  // validator: (val){
                  //   return RegExp(
                  //       r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  //       .hasMatch(val!)
                  //       ? null
                  //       : "Please enter a valid email";
                  // },
                ),
              ),

              SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: TextFormField(
                  obscureText: visible,
                  style: TextStyle(color: Colors.white),
                  decoration: textInputDecoration.copyWith(
                    labelText: "Password",
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.white,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: (){
                        setState(() {
                          visible = !visible;
                        });
                      },
                      child: Icon(
                        visible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                    )
                  ),
                  onChanged: (val){
                    setState(() {
                      password = val;
                      //debugPrint(password);
                    });
                  },
                  validator: (val) {
                    if (val!.length < 6) {
                      return "Password must be at least 6 characters";
                    } else {
                      return null;
                    }
                  },
                ),
              ),

              SizedBox(height:30),

              SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: const Text(
                    "SIGN IN",
                    style:
                    TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'FuturaBold'),
                  ),
                  onPressed: () {
                    login();
                  },
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'FuturaBold',
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => registerpage(
                          )));
                    },
                    child: Text (
                      "Sign Up!",
                      style: TextStyle(
                        color: Colors.blue,
                        fontFamily: 'FuturaBold',
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      )
    );
  }

  login() async{
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      QuerySnapshot snapshot1 = await FirebaseFirestore.instance.collection(
          "usernames").where("userName", isEqualTo: userName).get();
      if (snapshot1.docs.isEmpty) {
        setState(() {
          isLoading = false;
        });
        showSnackbar(context, "Enter valid username", Colors.red);
      }
      else {
        String email = snapshot1.docs[0]['email'];
        try {
          User user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email, password: password)).user!;
          if (user != null) {
            QuerySnapshot snapshot2 = await FirebaseFirestore.instance
                .collection("users")
                .where("userName", isEqualTo: userName)
                .get();
            SharedPreferences sf = await SharedPreferences.getInstance();
            await sf.setString('userLoggedInKey', 'SignedIn');
            await sf.setString('firebaseKey', user.uid);
            person.firebaseKey = user.uid;
            await sf.setString('userName', userName);
            person.userName = userName;
            await sf.setString('firstName', snapshot2.docs[0]['firstName']);
            person.firstName = snapshot2.docs[0]['firstName'];
            await sf.setString('lastName', snapshot2.docs[0]['lastName']);
            person.lastName = snapshot2.docs[0]['lastName'];
            await sf.setString('email', email);
            person.email = email;
            await sf.setString('pos', snapshot2.docs[0]['pos']);
            person.pos = snapshot2.docs[0]['pos'];
            await sf.setInt('goals', snapshot2.docs[0]['goals']);
            person.goals = snapshot2.docs[0]['goals'];
            await sf.setInt('assists', snapshot2.docs[0]['assists']);
            person.assists = snapshot2.docs[0]['assists'];
            await sf.setString('dpPath', snapshot2.docs[0]['dpLocalPath']);
            person.dpPath = snapshot2.docs[0]['dpLocalPath'];
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) =>
                    homepage(
                      person: person,
                    )), (route) => false);
          }
        } on FirebaseException catch (e) {
          setState(() {
            isLoading = false;
          });
          showSnackbar(context, e.message, Colors.red);
        }
      }
    }
  }

}//request.auth!=null

const textInputDecoration = InputDecoration(
  labelStyle: TextStyle(color: Colors.white),

  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue, width: 2),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2),
  ),
);