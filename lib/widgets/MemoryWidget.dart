import 'dart:async';

import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/models/MemoryProfile.dart';
import 'package:beena_social_app/models/user.dart';
import 'package:beena_social_app/pages/FullScreenImage.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/pages/MemoryComments.dart';
import 'package:beena_social_app/pages/ProfilePage.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:marquee/marquee.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class Memory extends StatefulWidget {
  final String memoryId;
  final String ownerId;
  final String subUserId;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String urlImage1;
  final String urlImage2;
  final String urlImage3;
  final String urlRecording;
  final Timestamp timestamp;

  Memory(
      {this.memoryId,
      this.ownerId,
      this.subUserId,
      this.likes,
      this.username,
      this.description,
      this.location,
      this.urlImage1,
      this.urlImage2,
      this.urlImage3,
      this.urlRecording,
      this.timestamp});

  factory Memory.fromDocument(DocumentSnapshot documentSnapshot) {
    return Memory(
      memoryId: documentSnapshot['memoryId'],
      ownerId: documentSnapshot['userId'],
      subUserId: documentSnapshot['subUserId'],
      likes: documentSnapshot['likes'],
      username: documentSnapshot['username'],
      description: documentSnapshot['description'],
      location: documentSnapshot['location'],
      urlImage1: documentSnapshot['urlImage1'],
      urlImage2: documentSnapshot['urlImage2'],
      urlImage3: documentSnapshot['urlImage3'],
      urlRecording: documentSnapshot['urlRecording'],
      timestamp: documentSnapshot['timestamp'],
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
        subUserId: this.subUserId,
        likes: this.likes,
        username: this.username,
        description: this.description,
        location: this.location,
        urlImage1: this.urlImage1,
        urlImage2: this.urlImage2,
        urlImage3: this.urlImage3,
        urlRecording: this.urlRecording,
        likeCount: getTotalNumberOfLikes(this.likes),
        timestamp: this.timestamp,
      );
}

class _MemoryState extends State<Memory> {
  final String memoryId;
  final String ownerId;
  final String subUserId;
  Map likes;
  final String username;
  final String description;
  final String location;
  final String urlImage1;
  final String urlImage2;
  final String urlImage3;
  final String urlRecording;
  final Timestamp timestamp;

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
    this.subUserId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.urlImage1,
    this.urlImage2,
    this.urlImage3,
    this.urlRecording,
    this.likeCount,
    this.timestamp,
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

    //retrieveComments();

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
            retrieveComments(),
            createMemoryPostFooter(),
          ],
        ),
      ),
    );
  }

  createMemoryPostHead() {
    return FutureBuilder(
      future: usersReference.document(ownerId).get(),
      //future: memoryUserReference.document(ownerId).get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return linearProgress();
        }
        User user = User.fromDocument(dataSnapshot.data);
        //MemoryProfile memoryUser = MemoryProfile.fromDocument(dataSnapshot.data);
        bool isPostOwner = (currentOnlineUserId == ownerId);
        return Container(
          color: colorWhite,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.url),
                //backgroundImage: CachedNetworkImageProvider(currentUser.url),
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
                        //currentUser.username,
                        user.username,
                        style: TextStyle(
                            color: colorBlack, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      location,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    Text(
                      timeAgo.format(timestamp.toDate()),
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 12),
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
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return FullScreenImage(
            screenType: 'memories',
            imageUrl: urlImage1,
            imageUrl2: urlImage2,
            imageUrl3: urlImage3,
          );
        }));
      },
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
                  CachedNetworkImage(
                    imageUrl: urlImage1,
                    fit: BoxFit.fill,
                  ),
                  if (urlImage2 != 'NA')
                    CachedNetworkImage(
                      imageUrl: urlImage2,
                      fit: BoxFit.fill,
                    ),
                  if (urlImage3 != 'NA')
                    CachedNetworkImage(
                      imageUrl: urlImage3,
                      fit: BoxFit.fill,
                    ),
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
          .collection('users')
          .document(subUserId)
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
          .collection('users')
          .document(subUserId)
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
        memoryCommentId: memoryId,
        memoryCommentOwnerId: ownerId,
        memoryCommentImageUrl: url,
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
  }

  void stop() {
    if (isPlaying) {
      audioPlayer.stop();
      isPlaying = false;
    }
  }

  retrieveComments() {
    return StreamBuilder(
      stream: memoryCommentsReference
          .document(memoryId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }

        String userData = "";
        dataSnapshot.data.documents.forEach((document) {
          var commentUserId = document['userId'];

          if (commentUserId != currentUser.id) {
            userData = '' +
                userData +
                document['username'] +
                ': ' +
                document['comment'] +
                '   ';
          }
        });

        return userData.length == 0
            ? Container()
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 3),
                height: 20,
                child: Marquee(
                  text: userData,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      fontFamily: 'Quicksand',
                      color: colorBlack),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  blankSpace: 10.0,
                  velocity: 90.0,
                  startPadding: 10.0,
                  accelerationCurve: Curves.linear,
                ),
              );
      },
    );
  }
}
