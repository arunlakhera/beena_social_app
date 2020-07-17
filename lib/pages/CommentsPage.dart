import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/widgets/HeaderWidget.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeAgo;

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
  TextEditingController commentsTextEditingController = TextEditingController();
  _CommentsPageState({this.postId, this.postOwnerId, this.postImageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: 'Comments'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: retrieveComments(),
            ),
            Divider(),
            ListTile(
              title: TextFormField(
                controller: commentsTextEditingController,
                decoration: InputDecoration(
                  labelText: 'Write comment here...',
                  labelStyle: TextStyle(color: colorWhite),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorGrey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorWhite)),
                ),
                style: TextStyle(color: colorWhite),
              ),
              trailing: OutlineButton(
                onPressed: saveComment,
                borderSide: BorderSide.none,
                child: Text(
                  'Publish',
                  style: TextStyle(
                    color: Colors.lightGreenAccent,
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

        return ListView(
          children: comments,
        );
      },
    );
  }

  saveComment() {
    commentsReference.document(postId).collection('comments').add({
      'username': currentUser.username,
      'comment': commentsTextEditingController.text,
      'timestamp': timeStamp,
      'url': currentUser.url,
      'userId': currentUser.id,
    });
    bool isNotPostOwner = (postOwnerId != currentUser.id);
    if (isNotPostOwner) {
      activityFeedReference.document(postOwnerId).collection('feedItems').add({
        'type': 'comment',
        'commentDate': DateTime.now(),
        'postId': postId,
        'userId': currentUser.id,
        'username': currentUser.username,
        'userProfileImg': currentUser.url,
        'url': postImageUrl,
      });
    }
    commentsTextEditingController.clear();
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;

  Comment({this.username, this.userId, this.url, this.comment, this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot documentSnapshot) {
    return Comment(
      username: documentSnapshot['username'],
      userId: documentSnapshot['userId'],
      url: documentSnapshot['url'],
      comment: documentSnapshot['comment'],
      timestamp: documentSnapshot['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Container(
        color: colorWhite,
        child: Column(
          children: [
            ListTile(
              title: Text(
                username + ':' + comment,
                style: TextStyle(fontSize: 18, color: colorBlack),
              ),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(url),
              ),
              subtitle: Text(
                timeAgo.format(timestamp.toDate()),
                style: TextStyle(color: colorBlack),
              ),
            )
          ],
        ),
      ),
    );
  }
}
