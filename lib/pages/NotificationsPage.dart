import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/pages/ProfilePage.dart';
import 'package:beena_social_app/widgets/HeaderWidget.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeAgo;

String notificationItemText;
Widget mediaPreview;

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      appBar: header(context, strTitle: 'Notification'),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 30,
              child: Text(
                'Been-a-Snap!',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Signatra',
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            Container(
              child: FutureBuilder(
                future: retrieveNotifications(),
                builder: (context, dataSnapshot) {
                  if (!dataSnapshot.hasData) {
                    return circularProgress();
                  }

                  return ListView(
                    children: dataSnapshot.data,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  retrieveNotifications() async {
    QuerySnapshot querySnapshot = await activityFeedReference
        .document(currentUser.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(60)
        .getDocuments();

    List<NotificationsItem> notificationsItems = [];
    querySnapshot.documents.forEach((document) {
      notificationsItems.add(NotificationsItem.fromDocument(document));
    });
    return notificationsItems;
  }
}

class NotificationsItem extends StatelessWidget {
  final String username;
  final String type;
  final String commentData;
  final String postId;
  final String userId;
  final String userProfileImg;
  final String url;
  final Timestamp timestamp;

  NotificationsItem(
      {this.username,
      this.type,
      this.commentData,
      this.postId,
      this.userId,
      this.userProfileImg,
      this.url,
      this.timestamp});

  factory NotificationsItem.fromDocument(DocumentSnapshot documentSnapshot) {
    return NotificationsItem(
      username: documentSnapshot['username'],
      type: documentSnapshot['type'],
      commentData: documentSnapshot['commentData'],
      postId: documentSnapshot['postId'],
      userId: documentSnapshot['userId'],
      userProfileImg: documentSnapshot['userProfileImg'],
      url: documentSnapshot['url'],
      timestamp: documentSnapshot['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.only(bottom: 2),
        child: Container(
          color: Colors.white70,
          child: ListTile(
            title: GestureDetector(
              onTap: () => displayUserProfile(context, userProfileId: userId),
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: TextStyle(fontSize: 14, color: colorBlack),
                  children: [
                    TextSpan(
                      text: username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: ' $notificationItemText'),
                  ],
                ),
              ),
            ),
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImg),
            ),
            subtitle: Text(
              timeAgo.format(timestamp.toDate()),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: mediaPreview,
          ),
        ),
      ),
    );
  }

  displayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(userProfileId: userProfileId)));
  }

  configureMediaPreview(context) {
    if (type == 'comment' || type == 'like') {
      mediaPreview = GestureDetector(
        onTap: () =>
            displayOwnerProfile(context, userProfileId: currentUser.id),
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text('');
    }

    if (type == 'like') {
      notificationItemText = 'liked your post.';
    } else if (type == 'comment') {
      notificationItemText = 'replied: $commentData';
    } else if (type == 'follow') {
      notificationItemText = 'started following you.';
    } else {
      notificationItemText = 'Error: Unknown Type: $type';
    }
  }

  displayOwnerProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(userProfileId: userProfileId)));
  }
}
