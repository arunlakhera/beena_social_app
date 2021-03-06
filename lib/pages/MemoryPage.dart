import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/models/user.dart';
import 'package:beena_social_app/pages/CreateMemory.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/pages/ProfilePage.dart';
import 'package:beena_social_app/widgets/HeaderWidget.dart';
import 'package:beena_social_app/widgets/MemoryWidget.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemoryPage extends StatefulWidget {
  final User googleCurrentUser;

  MemoryPage({this.googleCurrentUser});

  @override
  _MemoryPageState createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  List<Memory> memoryPosts = [];
  List<String> followingsList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int currentLength = 0;

  final int increment = 3;
  bool isLoading = false;

  ScrollController scrollController;

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
      appBar: header(context,
          isAppTitle: false, strTitle: 'Memories', hideBackButton: false),
      backgroundColor: colorOffWhite,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ProfilePage(
              userProfileId: currentUser.id,
              postsFlag: false,
              memoriesFlag: true,
            );
            //return null;
          }));
        },
        backgroundColor: colorBlack,
        foregroundColor: colorOffWhite,
        child: Icon(
          Icons.add,
          size: 40,
        ),
      ),
    );
  }

  createTimeLine() {
    if (memoryPosts == null) {
      return circularProgress();
    } else {
      return ListView.builder(
        itemCount: memoryPosts.length,
        itemBuilder: (context, index) {
          return memoryPosts[index];
        },
      );
    }
  }

  retrieveTimeLine() async {
    QuerySnapshot querySnapshot = await timelineReference
        .document(widget.googleCurrentUser.id)
        .collection('timelineMemory')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    List<Memory> allMemoryPosts = querySnapshot.documents
        .map((document) => Memory.fromDocument(document))
        .toList();

    if (!mounted) return;

    setState(() {
      this.memoryPosts = allMemoryPosts;
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
}
