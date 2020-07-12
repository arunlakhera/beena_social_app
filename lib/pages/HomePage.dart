import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/models/user.dart';
import 'package:beena_social_app/pages/CreateAccountPage.dart';
import 'package:beena_social_app/pages/NotificationsPage.dart';
import 'package:beena_social_app/pages/ProfilePage.dart';
import 'package:beena_social_app/pages/SearchPage.dart';
import 'package:beena_social_app/pages/TimeLinePage.dart';
import 'package:beena_social_app/pages/UploadPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersReference = Firestore.instance.collection('users');
final DateTime timeStamp = DateTime.now();
User currentUser;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSignedIn = false;

  PageController pageController;
  int getPageIndex = 0;

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
      body: SafeArea(
        child: PageView(
          children: [
            //TimeLinePage(),
            RaisedButton.icon(
                onPressed: googleLogoutUser,
                icon: Icon(Icons.close),
                label: Text('Sign Out')),
            SearchPage(),
            UploadPage(),
            NotificationsPage(),
            ProfilePage(),
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
                //Theme.of(context).accentColor,
                colorWhite,
                colorOffWhite,
                Theme.of(context).primaryColor,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade300,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(10, 10),
                      color: Colors.black38,
                      blurRadius: 20,
                    ),
                    BoxShadow(
                      offset: Offset(-10, -10),
                      color: Colors.white.withOpacity(0.85),
                      blurRadius: 20,
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
              SizedBox(height: 50),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: GoogleSignInButton(
                      onPressed: () {
                        googleLoginUser();
                      },
                      splashColor: Colors.deepOrangeAccent,
                      borderRadius: 5,
                    ),
                  ),
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
      documentSnapshot =
          await usersReference.document(googleCurrentUser.id).get();
    }
    currentUser = User.fromDocument(documentSnapshot);
  }
}
