import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/models/user.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/widgets/HeaderWidget.dart';
import 'package:beena_social_app/widgets/PostWidget.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimeLinePage extends StatefulWidget {
  final User googleCurrentUser;

  TimeLinePage({this.googleCurrentUser});

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  List<Post> posts = [];
  List<String> followingsList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int currentLength = 0;

  final int increment = 3;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    retrieveTimeLine();
    retrieveFollowings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorWhite,
      appBar: header(context,
          isAppTitle: false, strTitle: 'Posts', hideBackButton: false),
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
            InteractiveViewer(
              child: RefreshIndicator(
                child: createTimeLine(),
                onRefresh: () => retrieveTimeLine(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  retrieveTimeLine() async {
    QuerySnapshot querySnapshot = await timelineReference
        .document(widget.googleCurrentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    List<Post> allPosts = querySnapshot.documents
        .map((document) => Post.fromDocument(document))
        .toList();

    setState(() {
      this.posts = allPosts;
      retrieveFollowings();
    });
  }

  retrieveFollowings() async {
    QuerySnapshot querySnapshot = await followingReference
        .document(currentUser.id)
        .collection('userFollowing')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    if (!mounted) return;
    setState(() {
      followingsList = querySnapshot.documents
          .map((document) => document.documentID)
          .toList();
    });
  }

  createTimeLine() {
    if (posts == null) {
      return circularProgress();
    } else {
      return ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return posts[index];
        },
      );
    }
  }
}
