import 'dart:io';

import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/models/user.dart';
import 'package:beena_social_app/pages/CreateAccountPage.dart';
import 'package:beena_social_app/pages/MemoryPage.dart';
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
final StorageReference memoryStorageReference =
    FirebaseStorage.instance.ref().child('Memory Pictures');
final StorageReference recordingStorageReference =
    FirebaseStorage.instance.ref().child('Memory Recordings');
final postsReference = Firestore.instance.collection('posts');
final memoryReference = Firestore.instance.collection('memory');
final activityFeedReference = Firestore.instance.collection('feed');
final commentsReference = Firestore.instance.collection('comments');
final memoryCommentsReference = Firestore.instance.collection('memoryComments');
final followersReference = Firestore.instance.collection('followers');
final followingReference = Firestore.instance.collection('following');
final timelineReference = Firestore.instance.collection('timeline');

final DateTime timeStamp = DateTime.now();
User currentUser;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  PageController pageController;
  int getPageIndex = 0;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool isSignedIn = false;
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
  }

  @override
  void dispose() {
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
            MemoryPage(googleCurrentUser: currentUser),
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
        backgroundColor: colorWhite, //Theme.of(context).accentColor,
        activeColor: colorBlack,
        inactiveColor: Colors.blueGrey,
        items: [
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.commentAlt)),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.searchPlus)),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.pagelines)),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.cameraRetro)),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.solidHeart)),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.addressCard)),
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
                //Colors.blue.shade100.withOpacity(0.8),
                Color(0xFFf0f5fc),
                Colors.yellow.shade200,
                colorWhite,
                Color(0xFFf0f5fc),
                //Colors.deepPurple.withOpacity(0.2),
              ],
              begin: Alignment.topCenter,
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
                    child: Text(
                      'Been-A-snap!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 60,
                        fontFamily: 'Signatra',
                        letterSpacing: 3,
                        wordSpacing: 3,
                        shadows: [
                          Shadow(
                              offset: Offset(5, 5),
                              color: Colors.black38,
                              blurRadius: 6),
                          Shadow(
                            color: Colors.black.withOpacity(0.85),
                          )
                        ],
                        color: Colors.black87,
                        //color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: RaisedButton.icon(
                      color: colorWhite,
                      onPressed: () => googleLoginUser(),
                      icon: FaIcon(
                        FontAwesomeIcons.google,
                        color: Colors.red.shade900,
                        size: 25,
                      ),
                      label: Text('Sign In with Google'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
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
        'isVip': false,
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
