import 'package:baller_proj/profile.dart';
import 'package:baller_proj/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baller_proj/uploaddp.dart';
import 'package:flutter/material.dart';
import 'package:baller_proj/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baller_proj/login.dart';
import 'widgets.dart';

class profileEditPage extends StatefulWidget {
  final Person person;
  const profileEditPage({Key? key, required this.person}) : super(key: key);

  @override
  State<profileEditPage> createState() => _profileEditPageState();
}

class _profileEditPageState extends State<profileEditPage> {
  String firstName = "";
  bool fNChange = false;
  String userName = "";
  bool uNChange = false;
  String lastName = "";
  bool lNChange = false;
  String email = "";
  String pos = "";
  bool posChange = false;
  bool eChange = false;
  bool isLoading = false;

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
      body: isLoading ? Center(
          child: CircularProgressIndicator(
              color: Colors.white))
      : Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            DropdownButton(
                items: menuItems,
                menuMaxHeight: 500,
                hint: Padding(
                  padding: const EdgeInsets.fromLTRB(40,0,40,0),
                  child: Text(
                    pos.isEmpty ? "Player Position" : "$pos",
                    style: TextStyle(
                        color: Colors.white,
                      fontFamily: 'FuturaBold',
                    ),
                  ),
                ),
                onChanged: (val){
                  setState(() {
                    pos = val.toString();
                    posChange = true;
                  });
                }
            ),
            SizedBox(height:20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: textInputDecoration.copyWith(
                  labelText: "Username",
                  prefixIcon : Icon(
                    Icons.person,
                    color: Colors.white,
                  ),

                ),
                initialValue: "${widget.person.userName}",
                onChanged: (val){
                  setState(() {
                    userName = val;
                    uNChange = true;
                  });
                },
                validator: (val){
                  if (val!.isNotEmpty) {
                    return null;
                  } else {
                    return "Username cannot be empty";
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: TextFormField(
                style: TextStyle(
                    color: Colors.white,
                ),
                decoration: textInputDecoration.copyWith(
                  labelText: "First Name",
                  prefixIcon : Icon(
                      Icons.person,
                    color: Colors.white,
                  ),
                ),
                initialValue: "${widget.person.firstName}",
                onChanged: (val){
                  setState(() {
                    firstName = val;
                    fNChange = true;
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
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: textInputDecoration.copyWith(
                  labelText: "Last Name",
                  prefixIcon : Icon(
                      Icons.person,
                    color: Colors.white,
                  ),
                ),
                initialValue: "${widget.person.lastName}",
                onChanged: (val){
                  setState(() {
                    lastName = val;
                    lNChange = true;
                    //debugPrint(email);
                  });
                },
                validator: (val){
                  if (val!.isNotEmpty) {
                    return null;
                  } else {
                    return "Last name cannot be empty";
                  }
                },
              ),
            ),
            SizedBox(height: 50),

            ElevatedButton(
                onPressed: (){
                  confirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  )
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                  child: Text(
                    "CONFIRM",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: "FuturaBold"
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
  confirm() async {
    setState(() {
      isLoading = true;
    });
    if (uNChange == false) {
      setState(() {
        userName = widget.person.userName;
      });
    }
    if (fNChange == false) {
      setState(() {
        firstName = widget.person.firstName;
      });
    }
    if (lNChange == false) {
      setState(() {
        lastName = widget.person.lastName;
      });
    }
    if (posChange == false){
      setState(() {
        pos = widget.person.pos;
      });
    }
    if (formKey.currentState!.validate()) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(
          "usernames")
          .where("userName", isEqualTo: widget.person.userName)
          .get();
      String id = snapshot.docs[0].reference.id;
      //debugPrint(id);
      QuerySnapshot checker = await FirebaseFirestore.instance.collection(
          "usernames")
          .where("userName", isEqualTo: userName)
          .get();
      debugPrint(checker.docs.length.toString());
      if (checker.docs.isEmpty || userName ==
          widget.person.userName) { // check if username is already taken
        var usernames = await FirebaseFirestore.instance.collection(
            'usernames');
        var users = await FirebaseFirestore.instance.collection('users');
        usernames.doc(id).update({
          "userName": userName,
        });
        users.doc(id).update({
          "userName": userName,
          "firstName": firstName,
          "lastName": lastName,
          "pos": pos,
        });
        widget.person.lastName = lastName;
        widget.person.firstName = firstName;
        widget.person.userName = userName;
        widget.person.pos = pos;
        SharedPreferences sf = await SharedPreferences.getInstance();
        sf.setString('firstName', firstName);
        sf.setString('lastName', lastName);
        sf.setString('userName', userName);
        sf.setString('pos', pos);
        Navigator.pushReplacement(context, PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => profilepage(person: widget.person),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),);
      }
      else {
        setState(() {
          isLoading = false;
        });
        showSnackbar(context, "Username is already taken.", Colors.red);
      }
    }
  }
}
