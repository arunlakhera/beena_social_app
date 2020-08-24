import 'dart:async';

import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/models/user.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/pages/MemoryComments.dart';
import 'package:beena_social_app/pages/ProfilePage.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_pro/carousel_pro.dart';

class Memory extends StatefulWidget {
  final String memoryId;
  final String ownerId;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String urlImage1;
  final String urlImage2;
  final String urlImage3;
  final String urlRecording;

  Memory({
    this.memoryId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.urlImage1,
    this.urlImage2,
    this.urlImage3,
    this.urlRecording,
  });

  factory Memory.fromDocument(DocumentSnapshot documentSnapshot) {
    return Memory(
      memoryId: documentSnapshot['memoryId'],
      ownerId: documentSnapshot['ownerId'],
      likes: documentSnapshot['likes'],
      username: documentSnapshot['username'],
      description: documentSnapshot['description'],
      location: documentSnapshot['location'],
      urlImage1: documentSnapshot['urlImage1'],
      urlImage2: documentSnapshot['urlImage2'],
      urlImage3: documentSnapshot['urlImage3'],
      urlRecording: documentSnapshot['urlRecording'],
    );
  }

  int getTotalNumberOfLikes(likes) {
    if (likes == null) {
      return 0;
    }

    int counter = 0;
    likes.values.forEach((eachValue) {
      if (eachValue == true) {
        counter = counter + 1;
      }
    });
    return counter;
  }

  @override
  _MemoryState createState() => _MemoryState(
        memoryId: this.memoryId,
        ownerId: this.ownerId,
        likes: this.likes,
        username: this.username,
        description: this.description,
        location: this.location,
        urlImage1: this.urlImage1,
        urlImage2: this.urlImage2,
        urlImage3: this.urlImage3,
        urlRecording: this.urlRecording,
        likeCount: getTotalNumberOfLikes(this.likes),
      );
}

class _MemoryState extends State<Memory> {
  final String memoryId;
  final String ownerId;
  Map likes;
  final String username;
  final String description;
  final String location;
  final String urlImage1;
  final String urlImage2;
  final String urlImage3;
  final String urlRecording;

  int likeCount;
  bool isLiked;
  bool showHeart = false;
  final currentOnlineUserId = currentUser?.id;
  int commentCount = 0;
  Timer _timer;
  bool isPlaying = false;
  int currentDuration = 0;
  AudioPlayer audioPlayer = AudioPlayer();

  _MemoryState({
    this.memoryId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.urlImage1,
    this.urlImage2,
    this.urlImage3,
    this.urlRecording,
    this.likeCount,
  });

  @override
  void initState() {
    _timer = new Timer(Duration(milliseconds: 800), () {
      //setHeart();
      setState(() {
        showHeart = false;
      });
    });
    countMemoryPostComments();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentOnlineUserId] == true);
    return Card(
      elevation: 3,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            createMemoryPostHead(),
            createMemoryPostPicture(),
            createMemoryPostFooter(),
            //Divider(color: Colors.grey.shade800, thickness: 1),
          ],
        ),
      ),
    );
  }

  createMemoryPostHead() {
    return FutureBuilder(
      future: usersReference.document(ownerId).get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return linearProgress();
        }
        User user = User.fromDocument(dataSnapshot.data);
        bool isPostOwner = (currentOnlineUserId == ownerId);
        return Container(
          color: colorWhite,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.url),
                backgroundColor: colorGrey,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          displayUserProfile(context, userProfileId: user.id),
                      child: Text(
                        user.username,
                        style: TextStyle(
                            color: colorBlack, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      location,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              isPostOwner
                  ? IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: colorBlack,
                      ),
                      onPressed: () => controlPostDelete(context),
                    )
                  : Text(''),
            ],
          ),
        );
      },
    );
  }

  displayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(userProfileId: userProfileId)));
  }

  createMemoryPostPicture() {
    return GestureDetector(
      onDoubleTap: () => controlUserLikePost(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorWhite,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              height: 300.0,
              child: Carousel(
                images: [
                  NetworkImage(urlImage1),
                  if (urlImage2 != 'NA') NetworkImage(urlImage2),
                  if (urlImage3 != 'NA') NetworkImage(urlImage3),
                ],
                dotSize: 4.0,
                dotSpacing: 15.0,
                dotColor: Colors.lightGreenAccent,
                indicatorBgPadding: 5.0,
                dotBgColor: Colors.black87.withOpacity(0.5),
                borderRadius: true,
              ),
            ),
          ),
          showHeart
              ? Icon(Icons.favorite, size: 140, color: Colors.pink)
              : Text(''),
        ],
      ),
    );
  }

  createMemoryPostFooter() {
    return Container(
      color: colorWhite,
      padding: EdgeInsets.only(top: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Visibility(
            visible: (urlRecording != 'NA') ? true : false,
            child: Container(
              color: colorBlack,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (!isPlaying) {
                        play();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: colorBlack,
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(
                        Icons.arrow_right,
                        size: 25,
                        color: colorWhite,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      stop();
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: colorBlack,
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(
                        Icons.stop,
                        size: 25,
                        color: colorWhite,
                      ),
                    ),
                  ),
                  Container(
                    width: 50,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: colorBlack,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$currentDuration s',
                      style: TextStyle(
                          color: colorWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => controlUserLikePost(),
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 30,
                        color: Colors.pink,
                      ),
                    ),
                    Text(
                      '$likeCount likes',
                      style: TextStyle(
                        color: colorBlack,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => displayComments(context,
                    memoryId: memoryId, ownerId: ownerId, url: urlImage1),
                child: Container(
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 30,
                        color: Colors.pink,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '$commentCount comments',
                        style: TextStyle(
                          color: colorBlack,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: description.trim().length > 1
                              ? '$username : '
                              : '',
                          style: TextStyle(
                            color: colorBlack,
                            fontSize: 16,
                            fontFamily: 'Quicksand',
                          ),
                        ),
                        TextSpan(
                          text:
                              description.trim().length > 1 ? description : '',
                          style: TextStyle(
                            color: colorBlack,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            fontFamily: 'Quicksand',
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  controlUserLikePost() {
    bool _liked = likes[currentOnlineUserId] == true;

    if (_liked) {
      memoryReference
          .document(ownerId)
          .collection('usersMemory')
          .document(memoryId)
          .updateData({'likes.$currentOnlineUserId': false});
      removeLike();
      setState(() {
        likeCount = likeCount - 1;
        isLiked = false;
        likes[currentOnlineUserId] = false;
      });
    } else if (!_liked) {
      memoryReference
          .document(ownerId)
          .collection('usersMemory')
          .document(memoryId)
          .updateData({'likes.$currentOnlineUserId': true});

      addLike();
      setState(() {
        likeCount = likeCount + 1;
        isLiked = true;
        likes[currentOnlineUserId] = true;
        showHeart = true;
      });
      _timer = new Timer(Duration(milliseconds: 800), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  removeLike() {
    bool isNotPostOwner = currentOnlineUserId != ownerId;

    if (isNotPostOwner) {
      activityFeedReference
          .document(ownerId)
          .collection('feedItems')
          .document(memoryId)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });
    }
  }

  addLike() {
    bool isNotPostOwner = currentOnlineUserId != ownerId;

    if (isNotPostOwner) {
      activityFeedReference
          .document(ownerId)
          .collection('feedItems')
          .document(memoryId)
          .setData({
        'type': 'like',
        'username': currentUser.username,
        'userId': currentUser.id,
        'timestamp': DateTime.now(),
        'url': urlImage1,
        'memoryId': memoryId,
        'userProfileImg': currentUser.url
      });
    }
  }

  displayComments(BuildContext context,
      {String memoryId, String ownerId, String url}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MemoryComments(
        memoryId: memoryId,
        memoryOwnerId: ownerId,
        memoryImageUrl: url,
      );
    }));
  }

  controlPostDelete(BuildContext mContext) {
    return showDialog(
      context: mContext,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            'What do you want?',
            style: TextStyle(color: colorWhite),
          ),
          children: [
            SimpleDialogOption(
              child: Text('Delete this post',
                  style: TextStyle(
                      color: colorWhite, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(context);
                removeUserPost();
              },
            ),
            SimpleDialogOption(
              child: Text('Cancel',
                  style: TextStyle(
                      color: colorWhite, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  removeUserPost() async {
    // Delete the post
    postsReference
        .document(memoryId)
        .collection('usersMemory')
        .document(memoryId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    // Delete photo associated to the post
    memoryStorageReference.child('memory_$memoryId.jpg').delete();

    // Delete Notification for the pose
    QuerySnapshot querySnapshot = await activityFeedReference
        .document(ownerId)
        .collection('feedItems')
        .where('memoryId', isEqualTo: memoryId)
        .getDocuments();

    querySnapshot.documents.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    // Delete comments for the post
    QuerySnapshot deleteCommentsQuerySnapshot = await memoryCommentsReference
        .document(memoryId)
        .collection('comments')
        .getDocuments();

    deleteCommentsQuerySnapshot.documents.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
  }

  countMemoryPostComments() async {
    QuerySnapshot commentsQuerySnapshot = await memoryCommentsReference
        .document(memoryId)
        .collection('comments')
        .getDocuments();

    commentsQuerySnapshot.documents.forEach((document) {
      commentCount = commentCount + 1;
    });
  }

  void play() {
    if (urlRecording != null) {
      isPlaying = true;
      audioPlayer.play(urlRecording);

      audioPlayer.onPlayerCompletion.listen((event) {
        setState(() {
          isPlaying = false;
        });
      });

      audioPlayer.onAudioPositionChanged.listen((Duration cDuration) {
        setState(() {
          currentDuration = cDuration.inSeconds.toInt();
        });
      });
    }

//    if (recordFilePath != null && File(recordFilePath).existsSync()) {
//      AudioPlayer audioPlayer = AudioPlayer();
//      audioPlayer.play(recordFilePath, isLocal: true);
//      statusText = 'Playing...';
//      isPlaying = true;

//

//
//      audioPlayer.onDurationChanged.listen((Duration d) {
//        setState(() {
//          currentRecordingDuration = '$currentDuration s';
//        });
//      });
//    }
  }

  void stop() {
    if (isPlaying) {
      audioPlayer.stop();
      isPlaying = false;
    }
  }
}
