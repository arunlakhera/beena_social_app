import 'dart:io';

import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/models/user.dart';
import 'package:beena_social_app/pages/CreateAccountPage.dart';
import 'package:beena_social_app/pages/NotificationsPage.dart';
import 'package:beena_social_app/pages/ProfilePage.dart';
import 'package:beena_social_app/pages/SearchPage.dart';
import 'package:beena_social_app/pages/TimeLinePage.dart';
import 'package:beena_social_app/pages/UploadPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersReference = Firestore.instance.collection('users');
final StorageReference storageReference =
    FirebaseStorage.instance.ref().child('Posts Pictures');
final postsReference = Firestore.instance.collection('posts');
final activityFeedReference = Firestore.instance.collection('feed');
final commentsReference = Firestore.instance.collection('comments');
final followersReference = Firestore.instance.collection('followers');
final followingReference = Firestore.instance.collection('following');
final timelineReference = Firestore.instance.collection('timeline');

final DateTime timeStamp = DateTime.now();
User currentUser;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSignedIn = false;

  PageController pageController;
  int getPageIndex = 0;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();
    pageController = PageController();

    googleSignIn.onCurrentUserChanged.listen((googleSignInAccount) {
      controlGoogleSignIn(googleSignInAccount);
    }, onError: (googleError) {
      print('Error Message: $googleError');
    });

    googleSignIn
        .signInSilently(suppressErrors: false)
        .then((googleSignInAccount) => controlGoogleSignIn(googleSignInAccount))
        .catchError((googleError) {
      print('Error Message: $googleError');
    });

    // Animation
    controller = AnimationController(
        duration: Duration(seconds: 2), vsync: this, lowerBound: 0.5);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    controller.forward();

    controller.addStatusListener((status) {
      setState(() {
        if (status == AnimationStatus.completed) {
          controller.reverse(from: 1.0);
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    });
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return buildHomeScreen();
    } else {
      return buildSignInScreen();
    }
  }

  Widget buildHomeScreen() {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: PageView(
          children: [
            TimeLinePage(googleCurrentUser: currentUser),
            SearchPage(),
            UploadPage(googleCurrentUser: currentUser),
            NotificationsPage(),
            ProfilePage(userProfileId: currentUser.id),
          ],
          controller: pageController,
          onPageChanged: whenPageChanges,
          physics: NeverScrollableScrollPhysics(),
        ),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        backgroundColor: Theme.of(context).accentColor,
        activeColor: Colors.white,
        inactiveColor: Colors.blueGrey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
            size: 37,
          )),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
        ],
      ),
    );
  }

  Widget buildSignInScreen() {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black54,
                Colors.grey.shade800,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      //color: Colors.grey.shade300,
                      color: Colors.grey.shade800,
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(10, 10),
                          color: Colors.black38,
                          blurRadius: 40,
                        ),
                        BoxShadow(
                          offset: Offset(-10, -10),
//                      color: Colors.white.withOpacity(0.85),
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 40,
                        )
                      ],
                    ),
                    child: Text(
                      'Been-A-snap!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        shadows: [
                          Shadow(
                              offset: Offset(3, 3),
                              color: Colors.black38,
                              blurRadius: 10),
                          Shadow(
                              offset: Offset(-3, -3),
                              color: Colors.black.withOpacity(0.85),
                              blurRadius: 10)
                        ],
                        color: Colors.white, //Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => googleLoginUser(),
                    child: Hero(
                      tag: 'heart_black_1',
                      child: Transform.rotate(
                        angle: 0.0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: animation.value * 20,
                              vertical: animation.value * 10),
                          margin: EdgeInsets.only(bottom: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.deepOrange,
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.google,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
//                  Hero(
//                    tag: 'heart_black_1',
//                    child: Transform.rotate(
//                      angle: 0.0,
//                      child: Container(
//                        alignment: Alignment.center,
//                        padding: EdgeInsets.symmetric(
//                            horizontal: animation.value * 20,
//                            vertical: animation.value * 10),
//                        margin: EdgeInsets.only(bottom: 30),
//                        decoration: BoxDecoration(
//                          borderRadius: BorderRadius.circular(10),
//                          color: Colors.blueAccent,
//                        ),
//                        child: InkWell(
//                          onTap: () => googleLoginUser(),
//                          child: FaIcon(
//                            FontAwesomeIcons.facebookSquare,
//                            color: Colors.white,
//                            size: 30,
//                          ),
//                        ),
//                      ),
//                    ),
//                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  controlGoogleSignIn(GoogleSignInAccount signInAccount) async {
    if (signInAccount != null) {
      await saveUserInfoToFirestore();
      setState(() {
        isSignedIn = true;
      });

      configureRealTimePushNotifications();
    } else {
      setState(() {
        isSignedIn = false;
      });
    }
  }

  void googleLoginUser() {
    googleSignIn.signIn();
  }

  void googleLogoutUser() {
    googleSignIn.signOut();
  }

  void whenPageChanges(int pageIndex) {
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  void onTapChangePage(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 400),
      curve: Curves.bounceInOut,
    );
  }

  saveUserInfoToFirestore() async {
    final GoogleSignInAccount googleCurrentUser = googleSignIn.currentUser;
    DocumentSnapshot documentSnapshot =
        await usersReference.document(googleCurrentUser.id).get();

    if (!documentSnapshot.exists) {
      final username = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => CreateAccountPage()));

      usersReference.document(googleCurrentUser.id).setData({
        'id': googleCurrentUser.id,
        'profileName': googleCurrentUser.displayName,
        'username': username,
        'url': googleCurrentUser.photoUrl,
        'email': googleCurrentUser.email,
        'bio': '',
        'timestamp': timeStamp,
      });

      await followersReference
          .document(googleCurrentUser.id)
          .collection('userFollowers')
          .document(googleCurrentUser.id)
          .setData({});

      documentSnapshot =
          await usersReference.document(googleCurrentUser.id).get();
    }
    currentUser = User.fromDocument(documentSnapshot);
  }

  configureRealTimePushNotifications() {
    final GoogleSignInAccount googleUser = googleSignIn.currentUser;

    if (Platform.isIOS) {
      getIOSPermissions();
    }

    _firebaseMessaging.getToken().then((token) {
      usersReference
          .document(googleUser.id)
          .updateData({'androidNotificationToken': token});
    });

    _firebaseMessaging.configure(onMessage: (Map<String, dynamic> msg) async {
      final String recipientId = msg['data']['recipient'];
      final String body = msg['notification']['body'];

      if (recipientId == googleUser.id) {
        SnackBar snackBar = SnackBar(
          backgroundColor: Colors.grey,
          content: Text(
            body,
            style: TextStyle(
              color: colorBlack,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    });
  }

  getIOSPermissions() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));

    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print('settings registered: $settings');
    });
  }
}
