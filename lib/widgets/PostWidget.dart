import 'dart:async';

import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/models/user.dart';
import 'package:beena_social_app/pages/CommentsPage.dart';
import 'package:beena_social_app/pages/FullScreenImage.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/pages/ProfilePage.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;
  final Timestamp timestamp;

  Post({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
    this.timestamp,
  });

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postId: documentSnapshot['postId'],
      ownerId: documentSnapshot['ownerId'],
      likes: documentSnapshot['likes'],
      username: documentSnapshot['username'],
      description: documentSnapshot['description'],
      location: documentSnapshot['location'],
      url: documentSnapshot['url'],
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
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        likes: this.likes,
        username: this.username,
        description: this.description,
        location: this.location,
        url: this.url,
        timestamp: this.timestamp,
        likeCount: getTotalNumberOfLikes(this.likes),
      );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  Map likes;
  final String username;
  final String description;
  final String location;
  final String url;
  final Timestamp timestamp;
  int likeCount;
  var countFormat = new NumberFormat.compact();
  bool isLiked;
  bool showHeart = false;
  final currentOnlineUserId = currentUser?.id;
  int commentCount = 0;
  Timer _timer;

  _PostState({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
    this.timestamp,
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
    countPostComments();
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
            createPostHead(),
            createPostPicture(),
            createPostFooter(),
            //Divider(color: Colors.grey.shade800, thickness: 1),
          ],
        ),
      ),
    );
  }

  createPostHead() {
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
                    Visibility(
                      visible: location.length < 1 ? false : true,
                      child: Text(
                        location,
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 12),
                      ),
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

  createPostPicture() {
    return GestureDetector(
      onDoubleTap: () => controlUserLikePost(),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return FullScreenImage(
            screenType: 'post',
            imageUrl: url,
            imageUrl2: 'NA',
            imageUrl3: 'NA',
          );
        }));
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              border: Border.all(),
            ),
            child: CachedNetworkImage(
              imageUrl: url,
              progressIndicatorBuilder: (context, url, downloadProgress) {
                return Shimmer.fromColors(
                  child: Container(
                    height: 300,
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  loop: 5,
                );
              },
              errorWidget: (context, url, error) => Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Column(
                  children: [
                    Icon(Icons.error),
                    Text(
                      'Could not load Image...',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
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

  createPostFooter() {
    return Container(
      color: colorWhite,
      padding: EdgeInsets.only(top: 5, right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
                      '${NumberFormat.compact().format(likeCount)} likes',
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
                    postId: postId, ownerId: ownerId, url: url),
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
                        '${NumberFormat.compact().format(commentCount)} comments',
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
      postsReference
          .document(ownerId)
          .collection('usersPosts')
          .document(postId)
          .updateData({'likes.$currentOnlineUserId': false});
      removeLike();
      setState(() {
        likeCount = likeCount - 1;
        isLiked = false;
        likes[currentOnlineUserId] = false;
      });
    } else if (!_liked) {
      postsReference
          .document(ownerId)
          .collection('usersPosts')
          .document(postId)
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
          .document(postId)
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
          .document(postId)
          .setData({
        'type': 'like',
        'username': currentUser.username,
        'userId': currentUser.id,
        'timestamp': DateTime.now(),
        'url': url,
        'postId': postId,
        'userProfileImg': currentUser.url
      });
    }
  }

  displayComments(BuildContext context,
      {String postId, String ownerId, String url}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CommentsPage(
        postId: postId,
        postOwnerId: ownerId,
        postImageUrl: url,
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
        .document(ownerId)
        .collection('usersPosts')
        .document(postId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    // Delete photo associated to the post
    storageReference.child('post_$postId.jpg').delete();

    // Delete Notification for the pose
    QuerySnapshot querySnapshot = await activityFeedReference
        .document(ownerId)
        .collection('feedItems')
        .where('postId', isEqualTo: postId)
        .getDocuments();

    querySnapshot.documents.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    // Delete comments for the post
    QuerySnapshot deleteCommentsQuerySnapshot = await commentsReference
        .document(postId)
        .collection('comments')
        .getDocuments();

    deleteCommentsQuerySnapshot.documents.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
  }

  countPostComments() async {
    QuerySnapshot commentsQuerySnapshot = await commentsReference
        .document(postId)
        .collection('comments')
        .getDocuments();

    commentsQuerySnapshot.documents.forEach((document) {
      commentCount = commentCount + 1;
    });
  }
}
