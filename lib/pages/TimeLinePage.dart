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
  List<Post> posts;
  List<String> followingsList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
      appBar: header(context, isAppTitle: true),
      body: SafeArea(
        child: RefreshIndicator(
          child: createTimeLine(),
          onRefresh: () => retrieveTimeLine(),
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
        .getDocuments();
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
      return ListView(
        children: posts,
      );
    }
  }
}
