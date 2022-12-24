import 'dart:math';
import 'dart:io';
import 'dart:ui';
import 'package:baller_proj/uploadphoto.dart';
import 'package:baller_proj/uploadvideo.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:baller_proj/home.dart';
import 'package:baller_proj/login.dart';
import 'package:baller_proj/splashscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:baller_proj/search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baller_proj/widgets.dart';
import 'package:baller_proj/settings.dart';
import 'package:baller_proj/uploadphoto.dart';
import 'package:baller_proj/uploadvideo.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:uuid/uuid.dart';

//MAKE SURE TO HAVE BLANK DISPLAY PIC ALSO

class profilepage extends StatefulWidget {
  final Person person;
  const profilepage({Key? key, required this.person}) : super(key: key);

  @override
  State<profilepage> createState() => _profilepageState();
}

class _profilepageState extends State<profilepage> {
  late VideoPlayerController _controller;
  final ScrollController _scrollController = ScrollController();
  TextEditingController _textController = TextEditingController();
  double offset = 0.0;
  double scaleFactor = 1.0;
  int photosNum = 0;
  QuerySnapshot? photoPosts;
  int videosNum = 0;
  QuerySnapshot? videoPosts;
  List<dynamic> allPhotos = [];
  List<dynamic> allPhotoThumbnails = [];
  List<dynamic> allVideos = [];
  List<dynamic> allVideoThumbnails = [];
  bool isLoading = true;
  bool loadingPhoto = false;
  int likes = 0;
  bool? liked; //(for Photos)
  bool likedComment = false;
  String networkVideoURL = "";
  double? aspratio;
  double rating = 0;
  bool video = true;
  bool photo = false;
  bool team = false;
  bool more = true;
  bool viewComments = false;
  bool topComments = true;
  bool first = false;
  bool second = false;
  bool third = false;
  bool fourth = false;
  bool fifth = false;
  bool commentsLoading = false;
  DefaultCacheManager? manager;
  int initialPhotoCount = 0;
  int initialVideoCount = 0;
  List<dynamic> topCommentsList = [];
  List<dynamic> latestCommentsList = [];
  var ramUsage = 0;
  var videos = List<dynamic>.filled(1000, 0);
  var userRatingList = List<dynamic>.filled(1000, 0);
  var votesList = List<dynamic>.filled(1000, 0);
  var starsList = List<dynamic>.filled(1000, 0);
  final formKey = GlobalKey<FormState>();
  String lastPhotoDoc = "";
  bool noMorePhotos = false;
  String lastVidDoc = "";
  bool noMoreVids = false;
  String? docID;
  var docIDs = List<dynamic>.filled(1000, 0);
  var commentLikedMap = Map();
  var commentLikesMap = Map();

  @override
  void initState() {
    super.initState();
    manager = new DefaultCacheManager();
    loadPhotoPosts();
    loadVideoPosts();
    if (ramUsage > 300000000) {
      for (var i = 0; i < 1000; i++) {
        videos[i] = 0;
      }
      ramUsage = 0;
    }
    _scrollController.addListener(() {
      setState(() {
        offset = _scrollController.offset;
        scaleFactor = max(0.4, 1 / (max(1.0, min(50, offset / 100))));
      });
      double maxscroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (video == true) {
        if (!noMoreVids) {
          if (maxscroll - currentScroll < delta || offset == 0) {
            setState(() {
              if (initialVideoCount + 30 >= videosNum) {
                initialVideoCount = videosNum;
              } else {
                initialVideoCount += 30;
              }
            });
          }
        }
      }
      if (photo == true) {
        if (!noMorePhotos) {
          if (maxscroll - currentScroll < delta) {
            setState(() {
              if (initialPhotoCount + 30 >= photosNum) {
                initialPhotoCount = photosNum;
              } else {
                initialPhotoCount += 30;
              }
              paginatePhotos();
            });
          }
        }
      }
    });
    //debugPrint(initialPhotoCount.toString());
  }

  void dispose() {
    manager!.emptyCache();
    super.dispose();
  }

  Widget build(BuildContext context) {
    String firebaseKey = widget.person.firebaseKey;
    String firstName = widget.person.firstName;
    String lastName = widget.person.lastName;
    String userName = widget.person.userName;
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
    int goalsOrSaves = 0;
    int assists = 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: OverflowBox(
        child: Column(
          children: [
            SizedBox(height: 10),
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                settingspage(person: widget.person),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 58, 15, 0),
                        child: Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 58, 0, 0),
                      child: GestureDetector(
                        onTap: () {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      SizedBox(width: 25),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.grey[900],
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 10, 5, 10),
                                                  child: Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          5, 10, 10, 10),
                                                  child: Text(
                                                    "Make Team",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontFamily: 'FuturaBold',
                                                      decoration:
                                                          TextDecoration.none,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              color: Colors.white,
                                              height: 1,
                                              width: 120,
                                            ),
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 10, 5, 10),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      Navigator.push(
                                                        context,
                                                        PageRouteBuilder(
                                                          pageBuilder: (context,
                                                                  animation1,
                                                                  animation2) =>
                                                              uploadphotopage(
                                                                  person: widget
                                                                      .person),
                                                          transitionDuration:
                                                              Duration.zero,
                                                          reverseTransitionDuration:
                                                              Duration.zero,
                                                        ),
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.photo_camera,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          5, 10, 10, 10),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      Navigator.push(
                                                        context,
                                                        PageRouteBuilder(
                                                          pageBuilder: (context,
                                                                  animation1,
                                                                  animation2) =>
                                                              uploadphotopage(
                                                                  person: widget
                                                                      .person),
                                                          transitionDuration:
                                                              Duration.zero,
                                                          reverseTransitionDuration:
                                                              Duration.zero,
                                                        ),
                                                      );
                                                    },
                                                    child: Text(
                                                      "Photo",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'FuturaBold',
                                                        decoration:
                                                            TextDecoration.none,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              color: Colors.white,
                                              height: 1,
                                              width: 120,
                                            ),
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 10, 5, 10),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      Navigator.push(
                                                        context,
                                                        PageRouteBuilder(
                                                          pageBuilder: (context,
                                                                  animation1,
                                                                  animation2) =>
                                                              uploadvideopage(
                                                                  person: widget
                                                                      .person),
                                                          transitionDuration:
                                                              Duration.zero,
                                                          reverseTransitionDuration:
                                                              Duration.zero,
                                                        ),
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.video_camera_front,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          5, 10, 10, 10),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      Navigator.push(
                                                        context,
                                                        PageRouteBuilder(
                                                          pageBuilder: (context,
                                                                  animation1,
                                                                  animation2) =>
                                                              uploadvideopage(
                                                                  person: widget
                                                                      .person),
                                                          transitionDuration:
                                                              Duration.zero,
                                                          reverseTransitionDuration:
                                                              Duration.zero,
                                                        ),
                                                      );
                                                    },
                                                    child: Text(
                                                      "Video",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'FuturaBold',
                                                        decoration:
                                                            TextDecoration.none,
                                                      ),
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
                                ],
                              );
                            },
                          );
                        },
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5),
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.file(
                    File(widget.person.dpPath),
                    height: 300 * scaleFactor,
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
                          fontSize: 25 * scaleFactor,
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
                          fontSize: 35 * scaleFactor,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 300 * scaleFactor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                              fontSize: 18 * scaleFactor,
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
                              fontSize: 18 * scaleFactor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.white,
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Text(
                "@ ${userName}",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "FuturaBold",
                  fontSize: 20,
                ),
              ),
            ),
            Divider(
              color: Colors.white,
              height: 2,
            ),
            ///////////////////////////////////////////////////////////////////////////////////////
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      video = true;
                      photo = false;
                      team = false;
                      more = true;
                    });
                    _scrollController.animateTo(0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 50),
                    child: Icon(
                      Icons.sports_soccer_sharp,
                      color: video ? Colors.white : Colors.grey,
                      size: 30,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      video = false;
                      photo = true;
                      team = false;
                      more = true;
                    });
                    _scrollController.animateTo(0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 50),
                    child: Icon(
                      Icons.photo_camera,
                      color: photo ? Colors.white : Colors.grey,
                      size: 30,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      video = false;
                      photo = false;
                      team = true;
                    });
                    _scrollController.animateTo(0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 50),
                    child: Icon(
                      Icons.people,
                      color: team ? Colors.white : Colors.grey,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                AnimatedPadding(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: photo
                      ? EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 3)
                      : video
                          ? EdgeInsets.all(0)
                          : EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width / 3, 0, 0, 0),
                  child: Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width / 3,
                    color: Colors.white,
                  ),
                ),
                Divider(
                  color: Colors.white,
                  height: 2,
                ),
              ],
            ),
            Expanded(
              child: video
                  ? !isLoading
                      ? GridView.builder(
                          controller: _scrollController,
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent:
                                MediaQuery.of(context).size.width / 3,
                            childAspectRatio: 3 / 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: allVideos.length,
                          itemBuilder: (BuildContext ctx, index) {
                            return GestureDetector(
                              onTap: () {
                                !isLoading
                                    ? loadVideo(index)
                                    : CircularProgressIndicator(
                                        color: Colors.white);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: allVideoThumbnails[index],
                                      placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(
                                        color: Colors.white,
                                      )),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: CircularProgressIndicator(color: Colors.white))
                  : photo
                      ? !isLoading
                          ? GridView.builder(
                              controller: _scrollController,
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent:
                                    MediaQuery.of(context).size.width / 3,
                                childAspectRatio: 3 / 4,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: allPhotos.length,
                              itemBuilder: (BuildContext ctx, index) {
                                return GestureDetector(
                                  onTap: () {
                                    loadPhotoData(allPhotos[index]);
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl: allPhotoThumbnails[index],
                                          placeholder: (context, url) => Center(
                                              child: CircularProgressIndicator(
                                            color: Colors.white,
                                          )),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white))
                      : Container(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Divider(
                  color: Colors.grey,
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  homepage(person: widget.person),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                            (route) => false);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                        child: Icon(
                          Icons.home_rounded,
                          size: 35,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                searchpage(person: widget.person),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                        child: Icon(
                          Icons.search_rounded,
                          size: 35,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                profilepage(person: widget.person),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                        child: Icon(
                          Icons.person,
                          size: 35,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  loadPhotoPosts() async {
    allPhotos.clear();
    allPhotoThumbnails.clear();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("posts")
        .where("type", isEqualTo: "photo")
        .where("uploaderFirebaseKey", isEqualTo: widget.person.firebaseKey)
        .orderBy("date", descending: true)
        .limit(30)
        .get();
    setState(() {
      isLoading = false;
    });
    setState(() {
      photosNum = snapshot.docs.length;
      photoPosts = snapshot;
      if (photosNum < 30) {
        noMorePhotos = true;
      }
      lastPhotoDoc = snapshot.docs[snapshot.docs.length - 1].id.toString();
    });
    for (var i = 0; i < photosNum; i++) {
      allPhotos.add(photoPosts!.docs[i]["photoURL"]);
      allPhotoThumbnails.add(photoPosts!.docs[i]["photoThumbnailURL"]);
    }
  }

  paginatePhotos() async {
    DocumentSnapshot last = await FirebaseFirestore.instance
        .collection("posts")
        .doc(lastPhotoDoc)
        .get();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("posts")
        .where("type", isEqualTo: "photo")
        .where("uploaderFirebaseKey", isEqualTo: widget.person.firebaseKey)
        .orderBy("date", descending: true)
        .startAfter([last["date"]])
        .limit(30)
        .get();

    setState(() {
      photosNum = snapshot.docs.length;
      photoPosts = snapshot;
      if (photosNum < 30) {
        noMorePhotos = true;
      }
      lastPhotoDoc = snapshot.docs[snapshot.docs.length - 1].id.toString();
    });

    for (var i = 0; i < photosNum; i++) {
      allPhotos.add(photoPosts!.docs[i]["photoURL"]);
      allPhotoThumbnails.add(photoPosts!.docs[i]["photoThumbnailURL"]);
    }
  }

  ///////// vvvvvv REWRITE THIS SHIT vvvvvv

  loadPhotoData(dynamic photoURL) async {
    String fullName = widget.person.firstName + " " + widget.person.lastName;
    setState(() {
      loadingPhoto = true;
    });
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("posts")
        .where("photoURL", isEqualTo: photoURL.toString())
        .get();
    setState(() {
      likes = snapshot.docs[0]["likes"];
      docID = snapshot.docs[0].id.toString();
    });
    String firebaseKey = snapshot.docs[0]["uploaderFirebaseKey"];
    QuerySnapshot snapshot2 = await FirebaseFirestore.instance
        .collection("likes")
        .doc(docID)
        .collection("likers")
        .where("__name__", isEqualTo: widget.person.firebaseKey)
        .get();
    if (snapshot2.docs.length > 0) {
      setState(() {
        liked = true;
      });
    } else {
      setState(() {
        liked = false;
      });
    }
    setState(() {
      loadingPhoto = false;
    });
    return showPhoto(photoURL, fullName);
  }

////////////////////////////////////////////////*****************************************************
  showPhoto(String url, String fullName) async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment:
                      MediaQuery.of(context).viewInsets.bottom != 0
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedScale(
                                    scale: viewComments ? 0.6 : 1,
                                    curve: Curves.easeInOut,
                                    duration: Duration(milliseconds: 100),
                                    child: AnimatedPadding(
                                      padding: !viewComments
                                          ? EdgeInsets.all(20)
                                          : EdgeInsets.all(5),
                                      curve: Curves.easeInOut,
                                      duration: Duration(milliseconds: 100),
                                      child: Text(
                                        "${fullName}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          decoration: TextDecoration.none,
                                          fontFamily: 'FuturaBold',
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AnimatedScale(
                                    scale: viewComments ? 0 : 1,
                                    curve: Curves.easeInOut,
                                    duration: Duration(milliseconds: 100),
                                    child: AnimatedPadding(
                                      padding: !viewComments
                                          ? EdgeInsets.fromLTRB(0, 20, 10, 20)
                                          : EdgeInsets.all(0),
                                      curve: Curves.easeInOut,
                                      duration: Duration(milliseconds: 100),
                                      child: GestureDetector(
                                        onTap: () {
                                          editPostButton(0, url, true);
                                        },
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          GestureDetector(
                            onDoubleTap: () {
                              if (liked! == false) {
                                likePhoto(url);
                                setState(() {
                                  liked = true;
                                  likes += 1;
                                });
                                debugPrint("1");
                              } else {
                                unlikePhoto(url);
                                setState(() {
                                  liked = false;
                                  likes -= 1;
                                });
                                debugPrint("0");
                              }
                            },
                            child: AnimatedContainer(
                              width: viewComments
                                  ? MediaQuery.of(context).size.width / 2
                                  : MediaQuery.of(context).size.width,
                              curve: Curves.easeInOut,
                              duration: Duration(milliseconds: 100),
                              child: CachedNetworkImage(
                                imageUrl: url,
                                placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.white,
                                )),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          ),
                          Stack(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 25, 0, 0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      viewComments = !viewComments;
                                      commentsLoading = true;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        viewComments
                                            ? "Hide Comments "
                                            : "View Comments ",
                                        style: TextStyle(
                                          fontFamily: 'FuturaBold',
                                          color: Colors.blue[400],
                                          decoration: TextDecoration.none,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Icon(
                                        viewComments
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward,
                                        color: Colors.blue[400],
                                        size: 12,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${likes} ",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'FuturaBold',
                                        decoration: TextDecoration.none,
                                        fontSize: 20,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (liked! == false) {
                                          likePhoto(url);
                                          setState(() {
                                            liked = true;
                                            likes += 1;
                                          });
                                          debugPrint("1");
                                        } else {
                                          unlikePhoto(url);
                                          setState(() {
                                            liked = false;
                                            likes -= 1;
                                          });
                                          debugPrint("0");
                                        }
                                      },
                                      child: Icon(
                                        liked! == false
                                            ? Icons.star_border
                                            : Icons.star,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          AnimatedScale(
                            scale: viewComments ? 1 : 0,
                            curve: Curves.easeInOut,
                            duration: Duration(milliseconds: 100),
                            child: Column(
                              children: [
                                AnimatedPadding(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeInOut,
                                  padding: viewComments
                                      ? EdgeInsets.fromLTRB(0, 10, 0, 10)
                                      : EdgeInsets.all(0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            topComments = true;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            "Top",
                                            style: TextStyle(
                                              color: topComments
                                                  ? Colors.white
                                                  : Colors.grey,
                                              fontFamily: 'FuturaBold',
                                              fontSize: 16,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            topComments = false;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            "Latest",
                                            style: TextStyle(
                                              color: !topComments
                                                  ? Colors.white
                                                  : Colors.grey,
                                              fontFamily: 'FuturaBold',
                                              fontSize: 16,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedScale(
                            duration: Duration(milliseconds: 100),
                            scale: viewComments ? 1 : 0,
                            child: AnimatedPadding(
                              duration: Duration(milliseconds: 100),
                              padding: viewComments
                                  ? EdgeInsets.fromLTRB(25, 10, 25, 10)
                                  : EdgeInsets.all(0),
                              child: Material(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                                child: viewComments
                                    ? TextFormField(
                                        controller: _textController,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          decoration: TextDecoration.none,
                                        ),
                                        decoration: InputDecoration(
                                          suffixIcon: GestureDetector(
                                            onTap: () {
                                              addComment(_textController.text,
                                                  url, "photo", 0);
                                              _textController.clear();
                                              FocusScope.of(context)
                                                  .requestFocus(FocusNode());
                                            },
                                            child: Icon(
                                              Icons.arrow_forward,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          labelText: "Add Comment",
                                          labelStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      )
                                    : Container(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    viewComments
                        ? Expanded(
                            child: AnimatedScale(
                              scale: viewComments ? 1 : 0,
                              curve: Curves.easeInOut,
                              duration: Duration(milliseconds: 200),
                              child: FutureBuilder(
                                  future: loadAllComments(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasData) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 5, 0, 0),
                                          child: ListView.builder(
                                            itemCount: topComments
                                                ? topCommentsList.length
                                                : latestCommentsList.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[900],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                12, 12, 70, 12),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              topComments
                                                                  ? "   " +
                                                                      topCommentsList[
                                                                              index]
                                                                          [0] +
                                                                      "   "
                                                                  : "   " +
                                                                      latestCommentsList[
                                                                              index]
                                                                          [0] +
                                                                      "   ",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontFamily:
                                                                    'FuturaBold',
                                                                fontSize: 16,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                              ),
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                topComments
                                                                    ? topCommentsList[index]
                                                                            [1]
                                                                        .toString()
                                                                    : latestCommentsList[
                                                                        index][1],
                                                                overflow:
                                                                    TextOverflow
                                                                        .visible,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily:
                                                                      'FuturaBold',
                                                                  fontSize: 16,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 10, 8, 10),
                                                        child: topComments
                                                            ? Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    commentLikesMap[topCommentsList[index][3]]
                                                                            .toString() +
                                                                        " ",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .none,
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'FuturaBold',
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        if (commentLikedMap[topCommentsList[index][3]] ==
                                                                            0) {
                                                                          commentLikedMap[topCommentsList[index][3]] =
                                                                              1;
                                                                          commentLikesMap[topCommentsList[index][3]] +=
                                                                              1;
                                                                        } else {
                                                                          commentLikedMap[topCommentsList[index][3]] =
                                                                              0;
                                                                          commentLikesMap[topCommentsList[index][3]] -=
                                                                              1;
                                                                        }
                                                                      });
                                                                      likeComment(
                                                                          topCommentsList[index]
                                                                              [
                                                                              3]);
                                                                      setState(
                                                                          () {
                                                                        loadAllComments();
                                                                      });
                                                                    },
                                                                    child: Icon(
                                                                      (commentLikedMap[topCommentsList[index][3]] >
                                                                              0)
                                                                          ? Icons
                                                                              .star
                                                                          : Icons
                                                                              .star_border,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 16,
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    commentLikesMap[latestCommentsList[index][3]]
                                                                            .toString() +
                                                                        " ",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .none,
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'FuturaBold',
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        if (commentLikedMap[latestCommentsList[index][3]] ==
                                                                            0) {
                                                                          commentLikedMap[latestCommentsList[index][3]] =
                                                                              1;
                                                                          commentLikesMap[latestCommentsList[index][3]] +=
                                                                              1;
                                                                        } else {
                                                                          commentLikedMap[latestCommentsList[index][3]] =
                                                                              0;
                                                                          commentLikesMap[latestCommentsList[index][3]] -=
                                                                              1;
                                                                        }
                                                                      });
                                                                      likeComment(
                                                                          latestCommentsList[index]
                                                                              [
                                                                              3]);
                                                                      setState(
                                                                          () {
                                                                        loadAllComments();
                                                                      });
                                                                    },
                                                                    child: Icon(
                                                                      (commentLikedMap[latestCommentsList[index][3]] >
                                                                              0)
                                                                          ? Icons
                                                                              .star
                                                                          : Icons
                                                                              .star_border,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 16,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      );
                                    }
                                  }),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((val) {
      viewComments = false;
      _textController.clear();
      topCommentsList.clear();
      latestCommentsList.clear();
      topComments = true;
      commentLikedMap.clear();
    });
  }

  likePhoto(String url) async {
    await FirebaseFirestore.instance.collection("posts").doc(docID).update({
      "likes": likes,
    });
    await FirebaseFirestore.instance
        .collection("likes")
        .doc(docID)
        .collection("likers")
        .doc(widget.person.firebaseKey)
        .set({
      "liked": true,
    });
  }

  unlikePhoto(String url) async {
    await FirebaseFirestore.instance.collection("posts").doc(docID).update({
      "likes": likes,
    });
    await FirebaseFirestore.instance
        .collection("likes")
        .doc(docID)
        .collection("likers")
        .doc(widget.person.firebaseKey)
        .delete();
  }

  loadVideoPosts() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("posts")
        .where("type", isEqualTo: "video")
        .where("uploaderFirebaseKey", isEqualTo: widget.person.firebaseKey)
        .orderBy("date", descending: true)
        .limit(30)
        .get();

    setState(() {
      videosNum = snapshot.docs.length;
      if (snapshot.docs.length < 30) {
        noMoreVids = true;
        videoPosts = snapshot;
        lastVidDoc = snapshot.docs[snapshot.docs.length - 1].id.toString();
      }
    });
    for (var i = 0; i < videosNum; i++) {
      allVideos.add(videoPosts!.docs[i]["videoURL"]);
      allVideoThumbnails.add(videoPosts!.docs[i]["videoThumbnailURL"]);
    }

    setState(() {
      isLoading = false;
    });
  }

  paginateVideos() async {
    DocumentSnapshot last = await FirebaseFirestore.instance
        .collection("posts")
        .doc(lastVidDoc)
        .get();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("posts")
        .where("type", isEqualTo: "video")
        .where("uploaderFirebaseKey", isEqualTo: widget.person.firebaseKey)
        .orderBy("date", descending: true)
        .startAfter([last["date"]])
        .limit(30)
        .get();
    setState(() {
      videosNum = snapshot.docs.length;
      videoPosts = snapshot;
      if (snapshot.docs.length < 30) {
        noMoreVids = true;
      }
      lastVidDoc = snapshot.docs[snapshot.docs.length - 1].id.toString();
    });
    for (var i = 0; i < videosNum; i++) {
      allVideos.add(videoPosts!.docs[i]["videoURL"]);
      allVideoThumbnails.add(videoPosts!.docs[i]["videoThumbnailURL"]);
    }
  }

  loadVideo(int index) async {
    String fullName = widget.person.firstName + " " + widget.person.lastName;
    if (videos[index] == 0) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedScale(
                                scale: viewComments ? 0.6 : 1,
                                curve: Curves.easeInOut,
                                duration: Duration(milliseconds: 100),
                                child: AnimatedPadding(
                                  padding: !viewComments
                                      ? EdgeInsets.all(20)
                                      : EdgeInsets.all(5),
                                  curve: Curves.easeInOut,
                                  duration: Duration(milliseconds: 100),
                                  child: Text(
                                    "${widget.person.firstName} ${widget.person.lastName}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      decoration: TextDecoration.none,
                                      fontFamily: 'FuturaBold',
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedScale(
                                scale: viewComments ? 0 : 1,
                                curve: Curves.easeInOut,
                                duration: Duration(milliseconds: 100),
                                child: AnimatedPadding(
                                  padding: !viewComments
                                      ? EdgeInsets.fromLTRB(0, 20, 10, 20)
                                      : EdgeInsets.all(0),
                                  curve: Curves.easeInOut,
                                  duration: Duration(milliseconds: 100),
                                  child: GestureDetector(
                                    onTap: () {
                                      editPostButton(index, "", false);
                                    },
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "${likes} ",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'FuturaBold',
                                decoration: TextDecoration.none,
                                fontSize: 20,
                              ),
                            ),
                            Icon(
                              Icons.star_border,
                              color: Colors.white,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );

      var metadata = await FirebaseStorage.instance
          .refFromURL(allVideos[index])
          .getMetadata();

      var fileSize = metadata.size;
      setState(() {
        ramUsage += fileSize!;
      });

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("posts")
          .where("videoURL", isEqualTo: allVideos[index])
          .get();
      String id = snapshot.docs[0].id.toString();
      setState(() {
        votesList[index] = snapshot.docs[0]["votes"];
        starsList[index] = snapshot.docs[0]["stars"];
        docIDs[index] = id;
      });
      QuerySnapshot snapshot2 = await FirebaseFirestore.instance
          .collection("likes")
          .doc(id)
          .collection("likers")
          .where("__name__", isEqualTo: widget.person.firebaseKey)
          .get();
      if (snapshot2.docs.length == 0) {
        setState(() {
          userRatingList[index] = 0;
        });
      } else {
        var currLikes = snapshot2.docs[0]["stars"];
        if (currLikes == 1) {
          setState(() {
            userRatingList[index] = 1;
          });
        }
        if (currLikes == 2) {
          setState(() {
            userRatingList[index] = 2;
          });
        }
        if (currLikes == 3) {
          setState(() {
            userRatingList[index] = 3;
          });
        }
        if (currLikes == 4) {
          setState(() {
            userRatingList[index] = 4;
          });
        }
        if (currLikes == 5) {
          setState(() {
            userRatingList[index] = 5;
          });
        }
      }
      CachedVideoPlayerController _cachedController =
          await CachedVideoPlayerController.network(allVideos[index]);
      await _cachedController.initialize();
      await _cachedController.setLooping(true);
      await _cachedController.setVolume(1.0);
      videos[index] = _cachedController;
      Navigator.pop(context);
    }
    setState(() {
      if (votesList[index] != 0) {
        rating = starsList[index] / votesList[index];
      }
    });
    playVideo(index, fullName);
  }

  likeVideo(int index, int num) async {
    int origStarsGiven = userRatingList[index];
    int totalStars = starsList[index];
    int totalVotes = votesList[index];
    setState(() {
      userRatingList[index] = num;
      if (totalVotes == 0) {
        rating = num.toDouble();
        starsList[index] = totalStars + num;
        votesList[index] += 1;
      } else {
        rating = (totalStars - origStarsGiven + num) / totalVotes;
        starsList[index] = totalStars - origStarsGiven + num;
      }
    });
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("posts")
        .where("videoURL", isEqualTo: allVideos[index])
        .get();
    String id = snapshot.docs[0].id.toString();
    DocumentSnapshot snapshot2 = await FirebaseFirestore.instance
        .collection("likes")
        .doc(id)
        .collection("likers")
        .doc(widget.person.firebaseKey)
        .get();
    if (snapshot2.exists) {
      await FirebaseFirestore.instance
          .collection("likes")
          .doc(id)
          .collection("likers")
          .doc(widget.person.firebaseKey)
          .update({
        "stars": num,
      });
      await FirebaseFirestore.instance.collection("posts").doc(id).update({
        "stars": totalStars - origStarsGiven + num,
      });
      setState(() {
        starsList[index] = totalStars - origStarsGiven + num;
      });
    } else {
      await FirebaseFirestore.instance
          .collection("likes")
          .doc(id)
          .collection("likers")
          .doc(widget.person.firebaseKey)
          .set({
        "stars": num,
      });
      await FirebaseFirestore.instance.collection("posts").doc(id).update({
        "votes": totalVotes + 1,
        "stars": totalStars + num,
      });
    }
  }

  playVideo(int index, String fullName) async {
    setState(() {
      docID = docIDs[index].toString();
    });
    CachedVideoPlayerController vid = videos[index];
    vid.play();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment:
                      MediaQuery.of(context).viewInsets.bottom != 0
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedScale(
                                    scale: viewComments ? 0.6 : 1,
                                    curve: Curves.easeInOut,
                                    duration: Duration(milliseconds: 100),
                                    child: AnimatedPadding(
                                      padding: !viewComments
                                          ? EdgeInsets.all(20)
                                          : EdgeInsets.all(5),
                                      curve: Curves.easeInOut,
                                      duration: Duration(milliseconds: 100),
                                      child: Text(
                                        "$fullName",
                                        style: TextStyle(
                                          color: Colors.white,
                                          decoration: TextDecoration.none,
                                          fontFamily: 'FuturaBold',
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AnimatedScale(
                                    scale: viewComments ? 0 : 1,
                                    curve: Curves.easeInOut,
                                    duration: Duration(milliseconds: 100),
                                    child: AnimatedPadding(
                                      padding: !viewComments
                                          ? EdgeInsets.fromLTRB(0, 20, 10, 20)
                                          : EdgeInsets.all(0),
                                      curve: Curves.easeInOut,
                                      duration: Duration(milliseconds: 100),
                                      child: GestureDetector(
                                        onTap: () {
                                          editPostButton(index, "", false);
                                        },
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              vid.value.isPlaying ? vid.pause() : vid.play();
                            },
                            child: AnimatedContainer(
                              width: viewComments
                                  ? MediaQuery.of(context).size.width / 2.2
                                  : MediaQuery.of(context).size.width,
                              duration: Duration(milliseconds: 100),
                              child: AspectRatio(
                                aspectRatio: vid.value.aspectRatio,
                                child: CachedVideoPlayer(vid),
                              ),
                            ),
                          ),
                          Stack(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 20, 0, 0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      viewComments = !viewComments;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        viewComments
                                            ? "Hide Comments "
                                            : "View Comments ",
                                        style: TextStyle(
                                          fontFamily: 'FuturaBold',
                                          color: Colors.blue[400],
                                          decoration: TextDecoration.none,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Icon(
                                        viewComments
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward,
                                        color: Colors.blue[400],
                                        size: 12,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      votesList[index] == 0
                                          ? "0.0 "
                                          : rating.toStringAsFixed(1) + " ",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'FuturaBold',
                                        decoration: TextDecoration.none,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    first = true;
                                    second = false;
                                    third = false;
                                    fourth = false;
                                    fifth = false;
                                  });
                                  likeVideo(index, 1);
                                },
                                child: Icon(
                                  userRatingList[index] >= 1
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    first = true;
                                    second = true;
                                    third = false;
                                    fourth = false;
                                    fifth = false;
                                  });
                                  likeVideo(index, 2);
                                },
                                child: Icon(
                                  userRatingList[index] >= 2
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    first = true;
                                    second = true;
                                    third = true;
                                    fourth = false;
                                    fifth = false;
                                  });
                                  likeVideo(index, 3);
                                },
                                child: Icon(
                                  userRatingList[index] >= 3
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    first = true;
                                    second = true;
                                    third = true;
                                    fourth = true;
                                    fifth = false;
                                  });
                                  likeVideo(index, 4);
                                },
                                child: Icon(
                                  userRatingList[index] >= 4
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    first = true;
                                    second = true;
                                    third = true;
                                    fourth = true;
                                    fifth = true;
                                  });
                                  likeVideo(index, 5);
                                },
                                child: Icon(
                                  userRatingList[index] == 5
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          AnimatedScale(
                            scale: viewComments ? 1 : 0,
                            curve: Curves.easeInOut,
                            duration: Duration(milliseconds: 100),
                            child: Column(
                              children: [
                                AnimatedPadding(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeInOut,
                                  padding: viewComments
                                      ? EdgeInsets.fromLTRB(0, 10, 0, 10)
                                      : EdgeInsets.all(0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            topComments = true;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            "Top",
                                            style: TextStyle(
                                              color: topComments
                                                  ? Colors.white
                                                  : Colors.grey,
                                              fontFamily: 'FuturaBold',
                                              fontSize: 16,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            topComments = false;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            "Latest",
                                            style: TextStyle(
                                              color: !topComments
                                                  ? Colors.white
                                                  : Colors.grey,
                                              fontFamily: 'FuturaBold',
                                              fontSize: 16,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedScale(
                            duration: Duration(milliseconds: 100),
                            scale: viewComments ? 1 : 0,
                            child: AnimatedPadding(
                              duration: Duration(milliseconds: 100),
                              padding: viewComments
                                  ? EdgeInsets.fromLTRB(25, 10, 25, 10)
                                  : EdgeInsets.all(0),
                              child: Material(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                                child: viewComments
                                    ? TextFormField(
                                        controller: _textController,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          decoration: TextDecoration.none,
                                        ),
                                        decoration: InputDecoration(
                                          suffixIcon: GestureDetector(
                                            onTap: () {
                                              addComment(_textController.text,
                                                  "", "video", index);
                                              _textController.clear();
                                              FocusScope.of(context)
                                                  .requestFocus(FocusNode());
                                            },
                                            child: Icon(
                                              Icons.arrow_forward,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          labelText: "Add Comment",
                                          labelStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      )
                                    : Container(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    viewComments
                        ? Expanded(
                            child: AnimatedScale(
                              scale: viewComments ? 1 : 0,
                              curve: Curves.easeInOut,
                              duration: Duration(milliseconds: 200),
                              child: FutureBuilder(
                                  future: loadAllComments(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasData) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 5, 0, 0),
                                          child: ListView.builder(
                                            itemCount: topComments
                                                ? topCommentsList.length
                                                : latestCommentsList.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[900],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                12, 12, 70, 12),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              topComments
                                                                  ? "   " +
                                                                      topCommentsList[
                                                                              index]
                                                                          [0] +
                                                                      "   "
                                                                  : "   " +
                                                                      latestCommentsList[
                                                                              index]
                                                                          [0] +
                                                                      "   ",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontFamily:
                                                                    'FuturaBold',
                                                                fontSize: 16,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                              ),
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                topComments
                                                                    ? topCommentsList[index]
                                                                            [1]
                                                                        .toString()
                                                                    : latestCommentsList[
                                                                        index][1],
                                                                overflow:
                                                                    TextOverflow
                                                                        .visible,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily:
                                                                      'FuturaBold',
                                                                  fontSize: 16,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 10, 8, 10),
                                                        child: topComments
                                                            ? Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    commentLikesMap[topCommentsList[index][3]]
                                                                            .toString() +
                                                                        " ",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .none,
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'FuturaBold',
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        if (commentLikedMap[topCommentsList[index][3]] ==
                                                                            0) {
                                                                          commentLikedMap[topCommentsList[index][3]] =
                                                                              1;
                                                                          commentLikesMap[topCommentsList[index][3]] +=
                                                                              1;
                                                                        } else {
                                                                          commentLikedMap[topCommentsList[index][3]] =
                                                                              0;
                                                                          commentLikesMap[topCommentsList[index][3]] -=
                                                                              1;
                                                                        }
                                                                      });
                                                                      likeComment(
                                                                          topCommentsList[index]
                                                                              [
                                                                              3]);
                                                                      setState(
                                                                          () {
                                                                        loadAllComments();
                                                                      });
                                                                    },
                                                                    child: Icon(
                                                                      (commentLikedMap[topCommentsList[index][3]] >
                                                                              0)
                                                                          ? Icons
                                                                              .star
                                                                          : Icons
                                                                              .star_border,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 16,
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    commentLikesMap[latestCommentsList[index][3]]
                                                                            .toString() +
                                                                        " ",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .none,
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'FuturaBold',
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        if (commentLikedMap[latestCommentsList[index][3]] ==
                                                                            0) {
                                                                          commentLikedMap[latestCommentsList[index][3]] =
                                                                              1;
                                                                          commentLikesMap[latestCommentsList[index][3]] +=
                                                                              1;
                                                                        } else {
                                                                          commentLikedMap[latestCommentsList[index][3]] =
                                                                              0;
                                                                          commentLikesMap[latestCommentsList[index][3]] -=
                                                                              1;
                                                                        }
                                                                      });
                                                                      likeComment(
                                                                        latestCommentsList[index]
                                                                            [3]
                                                                      );
                                                                      setState(
                                                                          () {
                                                                        loadAllComments();
                                                                      });
                                                                    },
                                                                    child: Icon(
                                                                      (commentLikedMap[latestCommentsList[index][3]] >
                                                                              0)
                                                                          ? Icons
                                                                              .star
                                                                          : Icons
                                                                              .star_border,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 16,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      );
                                    }
                                  }),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((val) {
      vid.seekTo(Duration.zero);
      vid.pause();
      viewComments = false;
      _textController.clear();
      topCommentsList.clear();
      latestCommentsList.clear();
      topComments = true;
      commentLikedMap.clear();
    });
  }

  editPostButton(int index, String url, bool photoPost) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Edit",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'FuturaBold',
                      fontSize: 20,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 35),
                  GestureDetector(
                    onTap: () {
                      photoPost ? deletePhoto(url) : deleteVideo(index);
                    },
                    child: Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'FuturaBold',
                        fontSize: 20,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  deletePhoto(String url) async {
    String photoURL = url;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("posts")
        .where("photoURL", isEqualTo: photoURL.toString())
        .get();
    String photoThumbnailURL = snapshot.docs[0]["photoThumbnailURL"];
    snapshot.docs[0].reference.delete();
    await FirebaseStorage.instance.refFromURL(photoURL).delete();
    await FirebaseStorage.instance.refFromURL(photoThumbnailURL).delete();
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            profilepage(person: widget.person),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  deleteVideo(int index) async {
    String videoURL = allVideos[index];
    String videoThumbnailURL = allVideoThumbnails[index];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("posts")
        .where("videoURL", isEqualTo: videoURL.toString())
        .get();
    snapshot.docs[0].reference.delete();
    dynamic firebaseKey = widget.person.firebaseKey;
    await FirebaseStorage.instance.refFromURL(videoURL).delete();
    await FirebaseStorage.instance.refFromURL(videoThumbnailURL).delete();
    videos[videos.length - 1 - index] = 0;
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            profilepage(person: widget.person),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  addComment(String text, String url, String type, int index) async {
    String commentID = Uuid().v4();
    if (text.length > 0) {
      String docID = "";
      DateTime now = new DateTime.now();
      String date = now!.toString();
      int dateInt = int.parse(date[0] +
          date[1] +
          date[2] +
          date[3] +
          date[5] +
          date[6] +
          date[8] +
          date[9] +
          date[11] +
          date[12] +
          date[14] +
          date[15] +
          date[17] +
          date[18]);
      if (type == "video") {
        setState(() {
          docID = docIDs[index].toString();
        });
      } else {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection("posts")
            .where("photoURL", isEqualTo: url)
            .get();
        setState(() {
          docID = snapshot.docs[0].id.toString();
        });
      }
      await FirebaseFirestore.instance
          .collection("comments")
          .doc(docID)
          .collection("commenters")
          .doc(commentID)
          .set({
        "id": widget.person.firebaseKey,
        "comment": text,
        "userName": widget.person.userName,
        "likes": 0,
        "date": dateInt,
      });
    }
    ;
    latestCommentsList.insert(
        0, [widget.person.userName, text, widget.person.firebaseKey, docID]);
    commentLikedMap[docID] = 0;
    commentLikesMap[docID] = 0;
  }

  loadAllComments() async {
    await loadTopComments();
    await loadLatestComments();
    return true;
  }

  loadTopComments() async {
    if (topCommentsList.length == 0) {
      QuerySnapshot snapshot3 = await FirebaseFirestore.instance
          .collection("comments")
          .doc(docID)
          .collection("commenters")
          .orderBy("likes", descending: true)
          .limit(30)
          .get();
      for (var i = 0; i < min(snapshot3.docs.length, 30); i++) {
        QuerySnapshot snapshot4 = await FirebaseFirestore.instance
            .collection("commentLikes")
            .doc(snapshot3.docs[i].id.toString())
            .collection("likers")
            .where("__name__", isEqualTo: widget.person.firebaseKey)
            .get();
        topCommentsList.add([
          snapshot3.docs[i]["userName"],
          snapshot3.docs[i]["comment"],
          snapshot3.docs[i]["id"],
          snapshot3.docs[i].id.toString()
        ]);
        commentLikedMap[snapshot3.docs[i].id.toString()] =
            snapshot4.docs.length;
        commentLikesMap[snapshot3.docs[i].id.toString()] =
            snapshot3.docs[i]["likes"];
      }
    }
  }

  loadLatestComments() async {
    if (latestCommentsList.length == 0) {
      QuerySnapshot snapshot3 = await FirebaseFirestore.instance
          .collection("comments")
          .doc(docID)
          .collection("commenters")
          .orderBy("date", descending: true)
          .limit(30)
          .get();
      for (var i = 0; i < min(snapshot3.docs.length, 30); i++) {
        QuerySnapshot snapshot4 = await FirebaseFirestore.instance
            .collection("commentLikes")
            .doc(snapshot3.docs[i].id.toString())
            .collection("likers")
            .where("__name__", isEqualTo: widget.person.firebaseKey)
            .get();
        latestCommentsList.add([
          snapshot3.docs[i]["userName"],
          snapshot3.docs[i]["comment"],
          snapshot3.docs[i]["id"],
          snapshot3.docs[i].id.toString()
        ]);
        commentLikedMap[snapshot3.docs[i].id.toString()] =
            snapshot4.docs.length;
        commentLikesMap[snapshot3.docs[i].id.toString()] =
            snapshot3.docs[i]["likes"];
      }
    }
  }

  likeComment(String docID2) async {
    int currLikes = commentLikesMap[docID2];
    if (commentLikedMap[docID2] == 1) {
      await FirebaseFirestore.instance
          .collection("comments")
          .doc(docID)
          .collection("commenters")
          .doc(docID2)
          .update({
        "likes": currLikes,
      });
      await FirebaseFirestore.instance
          .collection("commentLikes")
          .doc(docID2)
          .collection("likers")
          .doc(widget.person.firebaseKey)
          .set({
        "liked": true,
      });
    } else {
      await FirebaseFirestore.instance
          .collection("comments")
          .doc(docID)
          .collection("commenters")
          .doc(docID2)
          .update({
        "likes": currLikes,
      });
      await FirebaseFirestore.instance
          .collection("commentLikes")
          .doc(docID2)
          .collection("likers")
          .doc(widget.person.firebaseKey)
          .delete();
    }
  }
}
