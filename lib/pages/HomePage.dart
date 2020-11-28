import 'dart:io';

import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/models/user.dart';
import 'package:beena_social_app/pages/CreateAccountPage.dart';
import 'package:beena_social_app/pages/MemoryPage.dart';
import 'package:beena_social_app/pages/NotificationsPage.dart';
import 'package:beena_social_app/pages/ProfilePage.dart';
import 'package:beena_social_app/pages/RegisterPage.dart';
import 'package:beena_social_app/pages/TimeLinePage.dart';
import 'package:beena_social_app/pages/UploadPage.dart';
import 'package:beena_social_app/utilities/AppColor.dart';
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
final StorageReference memoryUserStorageReference =
    FirebaseStorage.instance.ref().child('Memory User Pictures');
final StorageReference recordingStorageReference =
    FirebaseStorage.instance.ref().child('Memory Recordings');
final postsReference = Firestore.instance.collection('posts');
final memoryReference = Firestore.instance.collection('memory');
final memoryUserReference = Firestore.instance.collection('memoryUser');
final activityFeedReference = Firestore.instance.collection('feed');
final commentsReference = Firestore.instance.collection('comments');
final memoryCommentsReference = Firestore.instance.collection('memoryComments');
final followersReference = Firestore.instance.collection('followers');
final followingReference = Firestore.instance.collection('following');
final timelineReference = Firestore.instance.collection('timeline');

final DateTime timeStamp = DateTime.now();
User currentUser;
bool isSignedIn = false;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  PageController pageController;
  int getPageIndex = 0;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String emailId = '';
  String password;

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
        child: !isSignedIn
            ? Container()
            : PageView(
                children: [
                  TimeLinePage(googleCurrentUser: currentUser),
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
          BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.commentAlt,
                size: 25,
              ),
              activeIcon: FaIcon(
                FontAwesomeIcons.commentAlt,
                size: 25,
                color: Colors.green.shade600,
              ),
              title: Text('Posts')),
          BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.pagelines,
                size: 25,
              ),
              activeIcon: FaIcon(
                FontAwesomeIcons.pagelines,
                size: 25,
                color: Colors.green.shade600,
              ),
              title: Text('Memories')),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.cameraRetro),
            activeIcon: FaIcon(
              FontAwesomeIcons.cameraRetro,
              color: Colors.green.shade600,
            ),
          ),
          BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.solidHeart,
                size: 25,
              ),
              activeIcon: FaIcon(
                FontAwesomeIcons.solidHeart,
                size: 25,
                color: Colors.green.shade600,
              ),
              title: Text('Notification')),
          BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.addressCard,
                size: 25,
              ),
              activeIcon: FaIcon(
                FontAwesomeIcons.addressCard,
                size: 25,
                color: Colors.green.shade600,
              ),
              title: Text('Profile')),
        ],
      ),
    );
  }

  Widget buildSignInScreen() {
    return Scaffold(
      backgroundColor: AppColor.PageBgColorGrayGainsboro,
      body: SafeArea(
        child: SingleChildScrollView (
          child: Container(
            height: MediaQuery.of(context).size.height > MediaQuery.of(context).size.width ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Image.asset('assets/images/logo_3.png', width: 200, height: 100,),
                ),
                SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Welcome to Beena',
                    style: TextStyle(
                      color: AppColor.PageBgColorBlackRich,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Sign in to continue',
                    style: TextStyle(
                      color: AppColor.PageBgColorGray,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 25),

                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(5.0),
                  child: TextField(
                    controller: emailController,
                    autocorrect: true,
                    decoration: InputDecoration(
                      hintText: 'Email Id..',
                      prefixIcon: Icon(Icons.email),
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      filled: true,
                      fillColor: Colors.white54,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        borderSide: BorderSide(color: AppColor.PageBgColorGray, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: AppColor.PageBgColorDark, width: 2),
                      ),
                    ),
                    onChanged: (value){
                      setState(() {
                        emailId = emailController.text;
                      });
                    },
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(5.0),
                  child: TextField(
                    controller: emailController,
                    autocorrect: true,
                    decoration: InputDecoration(
                      hintText: 'Password...',
                      prefixIcon: Icon(Icons.remove_red_eye),
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      filled: true,
                      fillColor: Colors.white54,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        borderSide: BorderSide(color: AppColor.PageBgColorGray, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: AppColor.PageBgColorDark, width: 2),
                      ),
                    ),
                    onChanged: (value){
                      setState(() {
                        password = passwordController.text;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColor.PageBgColorDark,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColor.PageBgColorSkyBlue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: AppColor.PageBgColorLight,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  margin: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          height: 1.0,
                          color: AppColor.PageBgColorGray,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'OR',
                        style: TextStyle(
                          color: AppColor.PageBgColorDark,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 1.0,
                          color: AppColor.PageBgColorGray,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 10, right: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.PageBgColorDark),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: FlatButton.icon(
                    // minWidth: MediaQuery.of(context).size.width,
                    // height: 50,
                    //
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    focusColor: AppColor.PageBgColorRedRose,
                    onPressed: (){
                      googleLoginUser();
                    },
                    icon: FaIcon(
                      FontAwesomeIcons.google,
                      color: AppColor.PageBgColorRedCarmine,
                    ),
                    label: Text(
                      'Sign in with Google',
                      style: TextStyle(color: AppColor.PageBgColorBlackRich,),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 10, right: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.PageBgColorDark),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: FlatButton.icon(
                    // minWidth: MediaQuery.of(context).size.width,
                    // height: 50,
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    focusColor: AppColor.PageBgColorRedRose,
                    onPressed: (){

                    },
                    icon: FaIcon(
                      FontAwesomeIcons.facebookF,
                      color: AppColor.PageBgColorSkyBlue,
                    ),
                    label: Text(
                      'Sign in with Facebook',
                      style: TextStyle(color: AppColor.PageBgColorBlackRich,),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColor.PageBgColorBlueCrayola,
                          fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => RegisterPage()));
                      },
                      child: Text(
                        'Register',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor.PageBgColorSkyBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  ],
                ),
              ],
            ),
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
