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

//          usersReference
//              .document(document['userId'])
//              .snapshots()
//              .forEach((element) {
//            print('${element['username']} ${element['isVip']}');
//            isVIP = element['isVip'];
//          });
        });

        return ListView(
          children: comments,
        );
      },
    );
  }

  saveComment() {
    String userComment = commentsTextEditingController.text;

    if (userComment.length > 0) {
      commentsReference.document(postId).collection('comments').add({
        'username': currentUser.username,
        'comment': commentsTextEditingController.text,
        'timestamp': DateTime.now(),
        'url': currentUser.url,
        'userId': currentUser.id,
      });
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
    bool colorComment =
        (username == currentUser.username && currentUser.isVip) ? true : false;

    usersReference.document(userId).snapshots().forEach((element) {
      print('Data: ${element.data}');
      print('${element['username']} ${element['isVip']}');
      //myVIP = element['isVip'];
    });

    return Card(
      elevation: 3,
      child: Container(
        padding: EdgeInsets.only(bottom: 5),
        color: colorWhite,
        child: Column(
          children: [
            ListTile(
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: username + ': ',
                      style: TextStyle(fontSize: 18, color: colorBlack),
                    ),
                    TextSpan(
                      text: comment,
                      style: TextStyle(
                          fontSize: 18,
                          color: colorComment
                              ? Colors.yellow.shade900
                              : colorBlack),
                    )
                  ],
                ),
              ),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(url),
              ),
              subtitle: Text(
                timeAgo.format(timestamp.toDate()),
                style: TextStyle(
                  fontSize: 14,
                  color: colorBlack,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
