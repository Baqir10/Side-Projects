import 'package:flutter/material.dart';
import 'package:baller_proj/home.dart';
import 'package:baller_proj/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baller_proj/widgets.dart';

class registerpage extends StatefulWidget {
  const registerpage({Key? key}) : super(key: key);
  @override
  State<registerpage> createState() => _registerpageState();
}


class _registerpageState extends State<registerpage> {

  final Person person = Person();
  String userName = "";
  String firstname = "";
  String lastname = "";
  String email = "";
  String password = "";
  bool isLoading = false;
  String errorMessage = "";
  bool visible = true;
  String pos = "ST";

  List<DropdownMenuItem<String>> menuItems = [
    DropdownMenuItem(child: Text("ST"),value: "ST"),
    DropdownMenuItem(child: Text("LW"),value: "LW"),
    DropdownMenuItem(child: Text("RW"),value: "RW"),
    DropdownMenuItem(child: Text("CF"),value: "CF"),
    DropdownMenuItem(child: Text("LF"),value: "LF"),
    DropdownMenuItem(child: Text("RF"),value: "RF"),
    DropdownMenuItem(child: Text("CAM"),value: "CAM"),
    DropdownMenuItem(child: Text("LM"),value: "LM"),
    DropdownMenuItem(child: Text("RM"),value: "RM"),
    DropdownMenuItem(child: Text("CM"),value: "CM"),
    DropdownMenuItem(child: Text("CDM"),value: "CDM"),
    DropdownMenuItem(child: Text("CB"),value: "CB"),
    DropdownMenuItem(child: Text("LB"),value: "LB"),
    DropdownMenuItem(child: Text("RB"),value: "RB"),
    DropdownMenuItem(child: Text("LWB"),value: "RWB"),
    DropdownMenuItem(child: Text("GK"),value: "GK"),
  ];

  final formKey = GlobalKey<FormState>();

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
                  height: 100,
                ),

                SizedBox(height:25),

                DropdownButton(
                    items: menuItems,
                    menuMaxHeight: 500,
                    hint: Padding(
                      padding: const EdgeInsets.fromLTRB(40,0,40,0),
                      child: Text(
                        "Player Position: ${pos}",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'FuturaBold',
                        ),
                      ),
                    ),
                    onChanged: (val){
                      setState(() {
                        pos = val.toString();
                      });
                    }
                ),

                SizedBox(height:25),

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

                    validator: (val){
                      if (val!.isEmpty) {
                        return "Username cannot be empty";
                      }
                      else{
                        return null;
                      }
                    },
                  ),
                ),

                SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: textInputDecoration.copyWith(
                      labelText: "First Name",
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    onChanged: (val){
                      setState(() {
                        firstname = val;
                        //debugPrint(email);
                      });
                    },

                    validator: (val){
                      if (val!.isNotEmpty) {
                        return null;
                      } else {
                        return "First name cannot be empty";
                      }
                    },
                  ),
                ),

                SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: textInputDecoration.copyWith(
                      labelText: "Last Name",
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    onChanged: (val){
                      setState(() {
                        lastname = val;
                        //debugPrint(email);
                      });
                    },

                    validator: (val){
                      if (val!.isNotEmpty) {
                        return null;
                      } else {
                        return "First name cannot be empty";
                      }
                    },
                  ),
                ),

                SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: textInputDecoration.copyWith(
                      labelText: "Email",
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.white,
                      ),
                    ),
                    onChanged: (val){
                      setState(() {
                        email = val;
                        //debugPrint(email);
                      });
                    },

                    validator: (val){
                      return RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(val!)
                          ? null
                          : "Please enter a valid email";
                    },
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
                      "REGISTER",
                      style:
                      TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'FuturaBold'),
                    ),
                    onPressed: () {
                      register();
                    },
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        )
    );
  }

  register() async {
    // if pass validation
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // create user
        User user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email, password: password)).user!;
        List<String> empty = [];
        if (user != null) {
          await FirebaseFirestore.instance.collection("users")
              .doc(user.uid)
              .set({
            "userName" : userName,
            "firstName": firstname,
            "lastName": lastname,
            "pos" : pos,
            "posts" : [],
            "goals" : 0,
            "assists" : 0,
            "dpLocalPath" : "",
            "followers" : FieldValue.arrayUnion(empty),
            "following" : FieldValue.arrayUnion(empty),
          });
          await FirebaseFirestore.instance.collection('usernames').doc(user.uid).set({
            'userName' : userName,
            "email": email,
          });
          SharedPreferences sf = await SharedPreferences.getInstance();
          await sf.setString('userLoggedInKey', 'SignedIn');
          await sf.setString('firebaseKey', user.uid);
          person.firebaseKey = user.uid;
          await sf.setString('firstName', firstname);
          person.firstName = firstname;
          await sf.setString('lastName', lastname);
          person.lastName = lastname;
          await sf.setString('email', email);
          person.email = email;
          await sf.setString('userName', userName);
          person.userName = userName;
          await sf.setString('pos', pos);
          person.pos = pos;
          await sf.setInt('goals', 0);
          person.goals = 0;
          await sf.setInt('assists', 0);
          person.assists = 0;
          await sf.setString('dpPath', "");
          person.dpPath = "";
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
              builder: (context) => homepage(
                person : person,
              )), (route) => false);
        }
      } on FirebaseAuthException catch (e) {
        showSnackbar(context, e.message, Colors.red);
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  notValidUsername() async{
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("users").where("username", isEqualTo: userName).get();
    if (snapshot.size != 0){
      return true;
    }
    else {
      return false;
    }
  }
}

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

