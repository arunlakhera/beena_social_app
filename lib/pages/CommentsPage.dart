import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/widgets/HeaderWidget.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeAgo;

String commentPostId;
String commentPostOwnerId;
String commentPostImageUrl;

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
  final currentOnlineUserId = currentUser?.id;
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
    isLiked = (likes[currentOnlineUserId] == true);

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
    bool _liked = likes[currentOnlineUserId] == true;

    if (_liked) {
      commentsReference
          .document(commentPostId)
          .collection('comments')
          .document(commentId)
          .updateData({'likes.$currentOnlineUserId': false});

      removeLike();

      setState(() {
        likeCount = likeCount - 1;
        isLiked = false;
        likes[currentOnlineUserId] = false;
      });
    } else if (!_liked) {
      commentsReference
          .document(commentPostId)
          .collection('comments')
          .document(commentId)
          .updateData({'likes.$currentOnlineUserId': true});

      addLike();
      setState(() {
        likeCount = likeCount + 1;
        isLiked = true;
        likes[currentOnlineUserId] = true;
        showHeart = true;
      });
    }
  }

  removeLike() {
    bool isNotPostOwner = currentOnlineUserId != commentPostOwnerId;

    if (isNotPostOwner) {
      activityFeedReference
          .document(commentPostOwnerId)
          .collection('feedItems')
          .document(commentPostId)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });
    }
  }

  addLike() {
    bool isNotPostOwner = currentOnlineUserId != commentPostOwnerId;

    if (isNotPostOwner) {
      activityFeedReference
          .document(commentPostOwnerId)
          .collection('feedItems')
          .document(commentPostId)
          .setData({
        'type': 'like',
        'username': currentUser.username,
        'userId': currentUser.id,
        'timestamp': DateTime.now(),
        'url': commentPostImageUrl,
        'postId': commentPostId,
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

class CommentsPage extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postImageUrl;

  CommentsPage({this.postId, this.postOwnerId, this.postImageUrl});

  @override
  _CommentsPageState createState() => _CommentsPageState(
      postId: postId, postOwnerId: postOwnerId, postImageUrl: postImageUrl);
}

class _CommentsPageState extends State<CommentsPage> {
  final String postId;
  final String postOwnerId;
  final String postImageUrl;

  String commentId;

  Map likes;
  int likeCount;
  bool showHeart = false;
  final currentOnlineUserId = currentUser?.id;
  int commentCount = 0;
  bool isLiked;

  TextEditingController commentsTextEditingController = TextEditingController();
  _CommentsPageState({this.postId, this.postOwnerId, this.postImageUrl});

  @override
  Widget build(BuildContext context) {
    commentPostId = postId;

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
      stream: commentsReference
          .document(postId)
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
      commentsReference.document(postId).collection('comments').add({
        'commentId': '',
        'username': currentUser.username,
        'comment': commentsTextEditingController.text,
        'timestamp': DateTime.now(),
        'url': currentUser.url,
        'userId': currentUser.id,
        'likes': {},
      }).then((value) => updateComment(value.documentID));
      bool isNotPostOwner = (postOwnerId != currentUser.id);
      if (isNotPostOwner) {
        activityFeedReference
            .document(postOwnerId)
            .collection('feedItems')
            .add({
          'type': 'comment',
          'commentData': commentsTextEditingController.text,
          'postId': postId,
          'userId': currentUser.id,
          'username': currentUser.username,
          'userProfileImg': currentUser.url,
          'url': postImageUrl,
          'timestamp': timeStamp,
        });
      }
      commentsTextEditingController.clear();
    }
  }

  updateComment(String documentID) async {
    commentId = documentID;
    await commentsReference
        .document(postId)
        .collection('comments')
        .document(commentId)
        .updateData({'commentId': commentId});
  }
}
