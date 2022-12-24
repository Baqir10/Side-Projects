import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:baller_proj/splashscreen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:baller_proj/profile.dart';
import 'package:uuid/uuid.dart';

class uploadphotopage extends StatefulWidget {
  final Person person;
  const uploadphotopage({Key? key, required this.person}) : super(key: key);

  @override
  State<uploadphotopage> createState() => _uploadphotopageState();
}

class _uploadphotopageState extends State<uploadphotopage> {
  File? imageFile;
  File? imageFile2;
  File? compFile;
  File? compFile2;
  double height = 0;
  bool isLoading = false;



  pickImage() async {
    Directory dir = await getApplicationDocumentsDirectory();
    final compPath = dir.absolute.path + '/temp1.jpg';
    final imagePath = dir.absolute.path + '/temp2.jpg';
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      CroppedFile? crop = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          maxHeight: 1350,
          maxWidth: 1080,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          aspectRatio: CropAspectRatio(ratioX: 4, ratioY: 5),
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
        compFile2 = await FlutterImageCompress.compressAndGetFile(crop.path, compPath, quality: 50, minWidth: 240, minHeight: 320);
        imageFile2 = await FlutterImageCompress.compressAndGetFile(crop.path, imagePath, quality: 50, minWidth: 1080, minHeight: 1350);
        setState(() {
          compFile = compFile2;
          imageFile = imageFile2;
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: imageFile != null
          ? isLoading == false
              ? Column(
                  children: [
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            postPhoto();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              "Post",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'FuturaBold',
                                fontSize: 19,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Align(alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: MediaQuery.of(context).size.width * 95 / 100,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                imageFile!,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Text(
                    //   "Assist by :",
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontFamily: "FuturaBold",
                    //     fontSize: 20,
                    //   ),
                    // ),
                    SizedBox(height: 20),
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

  postPhoto() async {
    setState(() {
      isLoading = true;
    });
    DateTime now = new DateTime.now();
    String date = now!.toString();
    int dateInt = int.parse(date[0]+date[1]+date[2]+date[3]+date[5]+date[6]+date[8]+date[9]+date[11]+date[12]+date[14]+date[15]+date[17]+date[18]);
    String firebaseKey = widget.person.firebaseKey;
    String postID = Uuid().v4();
    String thumbnailID = postID + "_thumbnail";
    await FirebaseStorage.instance.ref().child(postID).putFile(imageFile!);
    String url = await FirebaseStorage.instance.ref().child(postID).getDownloadURL();
    await FirebaseStorage.instance.ref().child(thumbnailID).putFile(compFile!);
    String thumbnail_url = await FirebaseStorage.instance.ref().child(thumbnailID).getDownloadURL();
    await FirebaseFirestore.instance.collection("posts").doc(postID).set({
      "date" : dateInt,
      "uploaderFirebaseKey" : firebaseKey,
      "type" : "photo",
      "likes" : 0,
      "photoURL" : url,
      "photoThumbnailURL" : thumbnail_url,
    });
    Navigator.pop(context);
  }
}
