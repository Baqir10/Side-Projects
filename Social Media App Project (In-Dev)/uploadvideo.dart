import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:baller_proj/splashscreen.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_compress/video_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:baller_proj/widgets.dart';
import 'package:uuid/uuid.dart';

class uploadvideopage extends StatefulWidget {
  final Person person;
  const uploadvideopage({Key? key, required this.person}) : super(key: key);

  @override
  State<uploadvideopage> createState() => _uploadvideopageState();
}

class _uploadvideopageState extends State<uploadvideopage> {
  late VideoPlayerController _controller;

  File? imageFile;
  File? imageFile2;
  String? compFile;
  String? videoFile;
  bool thumbnailSelected = false;
  double? aspratio;
  bool mute = false;
  bool aspcheck = true;
  bool chosen = false;

  pickVideo() async {
    XFile? pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        videoFile = pickedFile.path;
        chosen = true;
      });
      _controller = VideoPlayerController.file(
        File(videoFile!),
      )..initialize().then((value) => {setState(() {})});
      _controller.setLooping(true);
    } else {
      Navigator.pop(context);
    }
  }

  pickImage() async {
    Directory dir = await getApplicationDocumentsDirectory();
    final imagePath = dir.absolute.path + '/temp3.jpg';
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      CroppedFile? crop = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          maxHeight: 1350,
          maxWidth: 1080,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 80,
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
        imageFile2 = await FlutterImageCompress.compressAndGetFile(
            crop.path, imagePath,
            quality: 50, minWidth: 1080, minHeight: 1350);
        setState(() {
          imageFile = imageFile2;
          thumbnailSelected = true;
          chosen = true;
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
    pickVideo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: chosen != false
          ? _controller.value.aspectRatio >= 0.75
              ? _controller.value.duration.inSeconds <= 120
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 60, 15, 20),
                                  child: GestureDetector(
                                    onTap: () {
                                      postVideo();
                                    },
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
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    mute = !mute;
                                  });
                                  if (mute == true) {
                                    setState(() {
                                      _controller.setVolume(0);
                                    });
                                  } else {
                                    setState(() {
                                      _controller.setVolume(1);
                                    });
                                  }
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 62, 0, 20),
                                  child: Icon(
                                    mute
                                        ? Icons.volume_up_rounded
                                        : Icons.volume_off_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[900],
                            ),
                            width: MediaQuery.of(context).size.width * 95 / 100,
                            child: GestureDetector(
                              onTap: () {
                                if (_controller.value.isPlaying) {
                                  _controller.pause();
                                } else {
                                  _controller.play();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: AspectRatio(
                                    aspectRatio: _controller.value.aspectRatio,
                                    child: VideoPlayer(_controller),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                                child: Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: thumbnailSelected
                                      ? Padding(
                                          padding: const EdgeInsets.all(2),
                                          child: Center(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.file(
                                                imageFile!,
                                                width: 80,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          height: 120,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.grey[950],
                                          ),
                                        ),
                                ),
                              )
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                chosen = false;
                              });
                              pickImage();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Select thumbnail",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Video Duration Must Be Less Than 2 Minutes",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(35, 60, 0, 0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
              : Stack(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Video Aspect Ratio Not Supported",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(35, 60, 0, 0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
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

  postVideo() async {
    setState(() {
      chosen = false;
    });
    DateTime now = new DateTime.now();
    String date = now!.toString();
    int dateInt = int.parse(date[0]+date[1]+date[2]+date[3]+date[5]+date[6]+date[8]+date[9]+date[11]+date[12]+date[14]+date[15]+date[17]+date[18]);
    await VideoCompress.setLogLevel(0);
    final info = await VideoCompress.compressVideo(videoFile!, quality: VideoQuality.Res1920x1080Quality, includeAudio: !mute);
    setState(() {
      compFile = info!.path;
    });
    String postID = Uuid().v4();
    await FirebaseStorage.instance
        .ref()
        .child(postID + "_thumbnail")
        .putFile(imageFile!);
    String url = await FirebaseStorage.instance
        .ref()
        .child(postID + "_thumbnail")
        .getDownloadURL();
    await FirebaseStorage.instance
        .ref()
        .child(postID)
        .putFile(File(compFile!));
    String url_Video =
        await FirebaseStorage.instance.ref().child(postID).getDownloadURL();
    await FirebaseFirestore.instance.collection("posts").doc(postID).set({
      "date" : dateInt,
      "uploaderFirebaseKey": widget.person.firebaseKey,
      "votes": 0,
      "stars": 0,
      "type": "video",
      "mute": mute,
      "videoThumbnailURL": url,
      "videoURL": url_Video,
    });

    Navigator.pop(context);
  }
}
