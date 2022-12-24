import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:baller_proj/profile.dart';
import 'package:baller_proj/settings.dart';
import 'package:flutter/material.dart';
import 'package:baller_proj/splashscreen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class uploaddppage extends StatefulWidget {
  final Person person;
  const uploaddppage({Key? key, required this.person}) : super(key: key);

  @override
  State<uploaddppage> createState() => _uploaddppageState();
}

class _uploaddppageState extends State<uploaddppage> {
  File? imageFile;
  double height = 0;
  bool isLoading = false;

  pickImage() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      CroppedFile? crop = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          maxHeight: 1080,
          maxWidth: 1080,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          aspectRatio: CropAspectRatio(ratioX: 800, ratioY: 533),
          uiSettings: [
            AndroidUiSettings(
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              statusBarColor: Colors.black,
              backgroundColor: Colors.black,
              activeControlsWidgetColor: Colors.blue,
              initAspectRatio: CropAspectRatioPreset.ratio5x4,
              lockAspectRatio: true,
              hideBottomControls: true,
            )
          ]);
      if (crop != null) {
        setState(() {
          imageFile = File(crop.path);
        });
      } else {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    pickImage();
  }

  Widget build(BuildContext context) {
    String firstName = widget.person.firstName;
    String lastName = widget.person.lastName;
    String userName = widget.person.userName;
    int goalsOrSaves = widget.person.goals;
    int assists = widget.person.assists;

    String goalOrSave = "";
    if (widget.person.pos == "GK") {
      setState(() {
        goalOrSave = "Saves";
      });
    } else {
      setState(() {
        goalOrSave = "Goals";
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: imageFile != null
          ? isLoading == false
              ? Column(
                  children: [
                    SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            updateDP();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 30, horizontal: 15),
                            child: Text(
                              "Change",
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 135),
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Image.file(
                            imageFile!,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                              child: Text(
                                "${firstName}\n${lastName}",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'FuturaBold',
                                  fontSize: 25,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                              child: Text(
                                "${widget.person.pos}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'FuturaBold',
                                  fontSize: 35,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 300,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    "${goalsOrSaves}\n${goalOrSave}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'FuturaBold',
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    "${assists}\nAssists",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'FuturaBold',
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              // Text(
              //   "Assist by :",
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontFamily: "FuturaBold",
              //     fontSize: 20,
              //   ),
              // ),
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                      ],
                    ),
                  ],
                )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              ],
            ),
    );
  }

  updateDP() async {
    setState(() {
      isLoading = true;
    });

    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    path = '$path/dp.jpg';
    File newImage = await imageFile!.copy(path);
    SharedPreferences sf = await SharedPreferences.getInstance();
    sf.setString('dpPath', path);
    setState(() {
      widget.person.dpPath = path;
    });
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("userName", isEqualTo: widget.person.userName)
        .get();
    String firebaseKey = snapshot.docs[0].reference.id;
    // await FirebaseStorage.instance
    //     .ref()
    //     .child(id + "_dp")
    //     .putFile(imageFile!);
    await FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseKey)
        .update({
        "dpLocalPath" : path,
        }
        );

    Navigator.pop(context, widget.person);

  }
}
