import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/widgets/HeaderWidget.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeAgo;

String memoryCommentId;
String memoryCommentOwnerId;
String memoryCommentImageUrl;

class Comment extends StatefulWidget {
  final String commentId;
  final String username;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;
  final dynamic likes;

  Comment({
    this.commentId,
    this.username,
    this.userId,
    this.url,
    this.comment,
    this.timestamp,
    this.likes,
  });

  factory Comment.fromDocument(DocumentSnapshot documentSnapshot) {
    return Comment(
      commentId: documentSnapshot['commentId'],
      username: documentSnapshot['username'],
      userId: documentSnapshot['userId'],
      url: documentSnapshot['url'],
      comment: documentSnapshot['comment'],
      timestamp: documentSnapshot['timestamp'],
      likes: documentSnapshot['likes'],
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
  _CommentState createState() => _CommentState(
        commentId: commentId,
        username: username,
        userId: userId,
        url: url,
        comment: comment,
        timestamp: timestamp,
        likes: this.likes,
        likeCount: getTotalNumberOfLikes(this.likes),
      );
}

class _CommentState extends State<Comment> {
  final String commentId;
  final String username;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;
  bool myVIP = false;
  bool isLiked = false;

  Map likes;
  int likeCount;
  bool showHeart = false;
  //final currentOnlineUserId = currentUser?.id;
  int commentCount = 0;
  var countFormat = new NumberFormat.compact();

  @override
  void initState() {
    getUserCommentColor(userId);
  }

  _CommentState(
      {this.commentId,
      this.username,
      this.userId,
      this.url,
      this.comment,
      this.timestamp,
      this.likes,
      this.likeCount});

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUser?.id] == true);

    return Card(
      elevation: 3,
      child: Container(
        padding: EdgeInsets.all(5),
        color: colorWhite,
        child: Column(
          children: [
            ListTile(
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: username + ': ',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    TextSpan(
                      text: comment,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                        color: myVIP ? Colors.yellow.shade900 : colorBlack,
                      ),
                    )
                  ],
                ),
              ),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(url),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: controlUserLikePost,
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 25,
                      color: Colors.grey.shade600.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    likeCount == 0
                        ? ''
                        : NumberFormat.compact().format(likeCount).toString(),
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 10,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  Text(
                    timeAgo.format(timestamp.toDate()),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  controlUserLikePost() {
    bool _liked = likes[currentUser?.id] == true;

    if (_liked) {
      memoryCommentsReference
          .document(memoryCommentId)
          .collection('comments')
          .document(commentId)
          .updateData({'likes.${currentUser?.id}': false});

      removeLike();

      setState(() {
        likeCount = likeCount - 1;
        isLiked = false;
        likes[currentUser?.id] = false;
      });
    } else if (!_liked) {
      memoryCommentsReference
          .document(memoryCommentId)
          .collection('comments')
          .document(commentId)
          .updateData({'likes.${currentUser?.id}': true});

      addLike();
      setState(() {
        likeCount = likeCount + 1;
        isLiked = true;
        likes[currentUser?.id] = true;
        showHeart = true;
      });
    }
  }

  removeLike() {
    bool isNotPostOwner = currentUser?.id != memoryCommentOwnerId;

    if (isNotPostOwner) {
      activityFeedReference
          .document(memoryCommentOwnerId)
          .collection('feedItems')
          .document(memoryCommentId)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });
    }
  }

  addLike() {
    bool isNotPostOwner = currentUser?.id != memoryCommentOwnerId;

    if (isNotPostOwner) {
      activityFeedReference
          .document(memoryCommentOwnerId)
          .collection('feedItems')
          .document(memoryCommentId)
          .setData({
        'type': 'like',
        'username': currentUser.username,
        'userId': currentUser.id,
        'timestamp': DateTime.now(),
        'url': memoryCommentOwnerId,
        'postId': memoryCommentId,
        'userProfileImg': currentUser.url
      });
    }
  }

  void getUserCommentColor(String userId) async {
    await usersReference.document(userId).snapshots().forEach((element) {
      setState(() {
        myVIP = element['isVip'];
      });
    });
  }
}

class MemoryComments extends StatefulWidget {
  final String memoryCommentId;
  final String memoryCommentOwnerId;
  final String memoryCommentImageUrl;

  MemoryComments(
      {this.memoryCommentId,
      this.memoryCommentOwnerId,
      this.memoryCommentImageUrl});

  @override
  _MemoryCommentsState createState() => _MemoryCommentsState(
      memoryId: memoryCommentId,
      memoryOwnerId: memoryCommentOwnerId,
      memoryImageUrl: memoryCommentImageUrl);
}

class _MemoryCommentsState extends State<MemoryComments> {
  final String memoryId;
  final String memoryOwnerId;
  final String memoryImageUrl;

  String commentId;

  Map likes;
  int likeCount;
  bool showHeart = false;
  final currentOnlineUserId = currentUser?.id;
  int commentCount = 0;
  bool isLiked;

  TextEditingController commentsTextEditingController = TextEditingController();
  _MemoryCommentsState(
      {this.memoryId, this.memoryOwnerId, this.memoryImageUrl});

  @override
  Widget build(BuildContext context) {
    memoryCommentId = memoryId;

    return Scaffold(
      backgroundColor: colorWhite,
      appBar: header(context, strTitle: 'Comments'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: retrieveComments()),
            Divider(),
            ListTile(
              title: TextFormField(
                controller: commentsTextEditingController,
                decoration: InputDecoration(
                  hintText: 'Write comment here...',
                  hintStyle: TextStyle(color: colorGrey),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorWhite)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorWhite)),
                ),
                style: TextStyle(color: colorBlack),
              ),
              trailing: OutlineButton(
                onPressed: saveComment,
                borderSide: BorderSide.none,
                child: Text(
                  'Publish',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        List<Comment> comments = [];
        dataSnapshot.data.documents.forEach((document) {
          comments.add(Comment.fromDocument(document));
        });

        return ListView(children: comments);
      },
    );
  }

  saveComment() {
    String userComment = commentsTextEditingController.text;

    if (userComment.length > 0) {
      memoryCommentsReference.document(memoryId).collection('comments').add({
        'commentId': '',
        'username': currentUser.username,
        'comment': commentsTextEditingController.text,
        'timestamp': DateTime.now(),
        'url': currentUser.url,
        'userId': currentUser.id,
        'likes': {},
      }).then((value) => updateComment(value.documentID));
      bool isNotPostOwner = (memoryOwnerId != currentUser.id);
      if (isNotPostOwner) {
        activityFeedReference
            .document(memoryOwnerId)
            .collection('feedItems')
            .add({
          'type': 'comment',
          'commentData': commentsTextEditingController.text,
          'postId': memoryId,
          'userId': currentUser.id,
          'username': currentUser.username,
          'userProfileImg': currentUser.url,
          'url': memoryCommentImageUrl,
          'timestamp': timeStamp,
        });
      }
      commentsTextEditingController.clear();
    }
  }

  updateComment(String documentID) async {
    commentId = documentID;
    await memoryCommentsReference
        .document(memoryId)
        .collection('comments')
        .document(commentId)
        .updateData({'commentId': commentId});
  }
}

//
// String memoryCommentId;
// String memoryOwnerId;
// String memoryImageUrl;
//
// class Comment extends StatefulWidget {
//   final String commentId;
//   final String username;
//   final String userId;
//   final String url;
//   final String comment;
//   final Timestamp timestamp;
//   final dynamic likes;
//
//   Comment({
//     this.commentId,
//     this.username,
//     this.userId,
//     this.url,
//     this.comment,
//     this.timestamp,
//     this.likes,
//   });
//
//   factory Comment.fromDocument(DocumentSnapshot documentSnapshot) {
//     return Comment(
//       commentId: documentSnapshot['memoryCommentId'],
//       username: documentSnapshot['username'],
//       userId: documentSnapshot['userId'],
//       url: documentSnapshot['url'],
//       comment: documentSnapshot['comment'],
//       timestamp: documentSnapshot['timestamp'],
//     );
//   }
//
//   int getTotalNumberOfLikes(likes) {
//     if (likes == null) {
//       return 0;
//     }
//
//     int counter = 0;
//     likes.values.forEach((eachValue) {
//       if (eachValue == true) {
//         counter = counter + 1;
//       }
//     });
//     return counter;
//   }
//
//   @override
//   _CommentState createState() => _CommentState(
//         commentId: commentId,
//         username: username,
//         userId: userId,
//         url: url,
//         comment: comment,
//         timestamp: timestamp,
//       );
// }
//
// class _CommentState extends State<Comment> {
//   final String commentId;
//   final String username;
//   final String userId;
//   final String url;
//   final String comment;
//   final Timestamp timestamp;
//   bool myVIP = false;
//
//   bool isLiked = false;
//
//   Map likes;
//   int likeCount;
//   bool showHeart = false;
//   final currentOnlineUserId = currentUser?.id;
//   int commentCount = 0;
//   var countFormat = new NumberFormat.compact();
//
//   @override
//   void initState() {
//     getUserCommentColor(userId);
//   }
//
//   _CommentState({
//     this.commentId,
//     this.username,
//     this.userId,
//     this.url,
//     this.comment,
//     this.timestamp,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     isLiked = (likes[currentOnlineUserId] == true);
//
//     return Card(
//       elevation: 3,
//       child: Container(
//         padding: EdgeInsets.only(bottom: 5),
//         color: colorWhite,
//         child: Column(
//           children: [
//             ListTile(
//               title: RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: username + ': ',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontStyle: FontStyle.italic,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     TextSpan(
//                       text: comment,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: 'Quicksand',
//                         color: myVIP ? Colors.yellow.shade900 : colorBlack,
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               leading: CircleAvatar(
//                 backgroundImage: CachedNetworkImageProvider(url),
//               ),
//               trailing: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   GestureDetector(
//                     onTap: controlUserLikePost,
//                     child: Icon(
//                       isLiked ? Icons.favorite : Icons.favorite_border,
//                       size: 25,
//                       color: Colors.green.shade300,
//                     ),
//                   ),
//                   Text(
//                     likeCount == 0 ? '' : '${countFormat.format(likeCount)}',
//                     style: TextStyle(
//                       color: Colors.grey.shade800,
//                       fontSize: 10,
//                       fontFamily: 'Quicksand',
//                     ),
//                   ),
//                 ],
//               ),
//               subtitle: Text(
//                 timeAgo.format(timestamp.toDate()),
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   controlUserLikePost() {
//     bool _liked = likes[currentOnlineUserId] == true;
//
//     if (_liked) {
//       memoryCommentsReference
//           .document(memoryCommentId)
//           .collection('comments')
//           .document(commentId)
//           .updateData({'likes.$currentOnlineUserId': false});
//
//       removeLike();
//
//       setState(() {
//         likeCount = likeCount - 1;
//         isLiked = false;
//         likes[currentOnlineUserId] = false;
//       });
//     } else if (!_liked) {
//       memoryCommentsReference
//           .document(memoryCommentId)
//           .collection('comments')
//           .document(commentId)
//           .updateData({'likes.$currentOnlineUserId': true});
//
//       addLike();
//       setState(() {
//         likeCount = likeCount + 1;
//         isLiked = true;
//         likes[currentOnlineUserId] = true;
//         showHeart = true;
//       });
//     }
//   }
//
//   removeLike() {
//     bool isNotPostOwner = currentOnlineUserId != memoryOwnerId;
//
//     if (isNotPostOwner) {
//       activityFeedReference
//           .document(memoryOwnerId)
//           .collection('feedItems')
//           .document(memoryCommentId)
//           .get()
//           .then((document) {
//         if (document.exists) {
//           document.reference.delete();
//         }
//       });
//     }
//   }
//
//   addLike() {
//     bool isNotPostOwner = currentOnlineUserId != memoryOwnerId;
//
//     if (isNotPostOwner) {
//       activityFeedReference
//           .document(memoryOwnerId)
//           .collection('feedItems')
//           .document(memoryCommentId)
//           .setData({
//         'type': 'like',
//         'username': currentUser.username,
//         'userId': currentUser.id,
//         'timestamp': DateTime.now(),
//         'url': memoryImageUrl,
//         'postId': memoryCommentId,
//         'userProfileImg': currentUser.url
//       });
//     }
//   }
//
//   void getUserCommentColor(String userId) async {
//     await usersReference.document(userId).snapshots().forEach((element) {
//       setState(() {
//         myVIP = element['isVip'];
//       });
//     });
//   }
// }
//
// class MemoryComments extends StatefulWidget {
//   final String memoryId;
//   final String memoryOwnerId;
//   final String memoryImageUrl;
//
//   MemoryComments({this.memoryId, this.memoryOwnerId, this.memoryImageUrl});
//
//   @override
//   _MemoryCommentsState createState() => _MemoryCommentsState(
//       memoryId: memoryId,
//       memoryOwnerId: memoryOwnerId,
//       memoryImageUrl: memoryImageUrl);
// }
//
// class _MemoryCommentsState extends State<MemoryComments> {
//   final String memoryId;
//   final String memoryOwnerId;
//   final String memoryImageUrl;
//
//   String commentId;
//
//   Map likes;
//   int likeCount;
//   bool showHeart = false;
//   final currentOnlineUserId = currentUser?.id;
//   int commentCount = 0;
//   bool isLiked;
//
//   TextEditingController commentsTextEditingController = TextEditingController();
//   _MemoryCommentsState(
//       {this.memoryId, this.memoryOwnerId, this.memoryImageUrl});
//
//   @override
//   Widget build(BuildContext context) {
//     memoryCommentId = memoryId;
//     return Scaffold(
//       backgroundColor: colorWhite,
//       appBar: header(context, strTitle: 'Comments'),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(child: retrieveComments()),
//             Divider(),
//             ListTile(
//               title: TextFormField(
//                 controller: commentsTextEditingController,
//                 decoration: InputDecoration(
//                   hintText: 'Write comment here...',
//                   hintStyle: TextStyle(color: colorGrey),
//                   enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: colorWhite)),
//                   focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: colorWhite)),
//                 ),
//                 style: TextStyle(color: colorBlack),
//               ),
//               trailing: OutlineButton(
//                 onPressed: saveComment,
//                 borderSide: BorderSide.none,
//                 child: Text(
//                   'Publish',
//                   style: TextStyle(
//                     color: Colors.green,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   retrieveComments() {
//     return StreamBuilder(
//       stream: memoryCommentsReference
//           .document(memoryId)
//           .collection('comments')
//           .orderBy('timestamp', descending: false)
//           .snapshots(),
//       builder: (context, dataSnapshot) {
//         if (!dataSnapshot.hasData) {
//           return circularProgress();
//         }
//         List<Comment> comments = [];
//         dataSnapshot.data.documents.forEach((document) {
//           comments.add(Comment.fromDocument(document));
//         });
//
//         return ListView(
//           children: comments,
//         );
//       },
//     );
//   }
//
//   saveComment() {
//     String userComment = commentsTextEditingController.text;
//
//     if (userComment.length > 0) {
//       memoryCommentsReference.document(memoryId).collection('comments').add({
//         'commentId': '',
//         'username': currentUser.username,
//         'comment': commentsTextEditingController.text,
//         'timestamp': DateTime.now(),
//         'url': currentUser.url,
//         'userId': currentUser.id,
//       }).then((value) => updateMemoryComment(value.documentID));
//       ;
//       bool isNotPostOwner = (memoryOwnerId != currentUser.id);
//       if (isNotPostOwner) {
//         activityFeedReference
//             .document(memoryOwnerId)
//             .collection('feedItems')
//             .add({
//           'type': 'comment',
//           'commentData': commentsTextEditingController.text,
//           'memoryId': memoryId,
//           'userId': currentUser.id,
//           'username': currentUser.username,
//           'userProfileImg': currentUser.url,
//           'url': memoryImageUrl,
//           'timestamp': timeStamp,
//         });
//       }
//       commentsTextEditingController.clear();
//     }
//   }
//
//   updateMemoryComment(String documentID) async {
//     commentId = documentID;
//     await memoryCommentsReference
//         .document(memoryId)
//         .collection('comments')
//         .document(commentId)
//         .updateData({'commentId': memoryCommentId});
//   }
// }
