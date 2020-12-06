import 'dart:io';
import 'package:beena_social_app/models/user.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/utilities/AppColor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//FirebaseUser currentUser;
FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController fullNameInputController;
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  TextEditingController confirmPwdInputController;

  @override
  void initState() {
    fullNameInputController = new TextEditingController();
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    confirmPwdInputController = new TextEditingController();
    super.initState();
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildRegisterScreen(context);
  }

  Widget buildRegisterScreen(context) {

    return Scaffold(
      key: _scaffoldKey,
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
            child: Form(
              key: _registerFormKey,
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
                      'Sign up to continue',
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
                    child: TextFormField(
                      controller: fullNameInputController,
                      autocorrect: true,
                      decoration: InputDecoration(
                        hintText: 'Full Name..',
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
                      validator: (value){
                        if (value.length < 3) {
                          return "Please enter a valid name.";
                        }
                        return null;
                      },
                      // onChanged: (value){
                      //   setState(() {
                      //     _fullName = _fullNameController.text;
                      //     if (value.isEmpty) {
                      //       return 'Please enter some text';
                      //     }
                      //   });
                      // },
                    ),
                  ),
                  SizedBox(height: 5),

                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(5.0),
                    child: TextFormField(
                      controller: emailInputController,
                      autocorrect: true,
                      decoration: InputDecoration(
                        hintText: 'Email Id..(john.doe@gmail.com)',
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
                      validator: emailValidator,
                      // onChanged: (value){
                      //   setState(() {
                      //     _userEmail = _emailController.text;
                      //   });
                      // },
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(5.0),
                    child: TextFormField(
                      controller: pwdInputController,
                      obscureText: true,
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
                      validator: pwdValidator,
                      // onChanged: (value){
                      //   setState(() {
                      //     _password = _passwordController.text;
                      //   });
                      // },
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(5.0),
                    child: TextFormField(
                      controller: confirmPwdInputController,
                      obscureText: true,
                      autocorrect: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password...',
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
                      onChanged: pwdValidator,
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: (){
                      _registerUser();
                    },
                    child: Container(
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
                        'Register',
                        style: TextStyle(
                          color: AppColor.PageBgColorLight,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
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
                              MaterialPageRoute(builder: (context) => HomePage()));
                        },
                        child: Text(
                          'Sign In',
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
      ),
    );
  }

  void _registerUser() async {

    if(_registerFormKey.currentState.validate()){
      if(pwdInputController.text == confirmPwdInputController.text){

        await _auth.createUserWithEmailAndPassword(
            email: emailInputController.text,
            password: pwdInputController.text)
        .then((value) {
          return saveUser();
        })
            .whenComplete(() {
              askToSignIn();
        });
        //     .then((value) => {
        //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage(signedIn: true,)), (_) => false),
        //     fullNameInputController.clear(),
        //     emailInputController.clear(),
        //     pwdInputController.clear(),
        //     confirmPwdInputController.clear()
        // })
        // .catchError((err) => print(err))
        // .catchError((err) => print(err));

        // FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailInputController.text, password: pwdInputController.text)
        //     .then((value) => {
        //   Firestore.instance
        //       .collection("users")
        //       .document(value.uid).setData({
        //     'id': currentUser.uid,
        //     'profileName': fullNameInputController.text,
        //     'username': emailInputController.text,
        //     'url': '',
        //     'email': emailInputController.text,
        //     'bio': '',
        //     'timestamp': timeStamp,
        //     'isVip': false,
        //   })
        // }).then((value) => {
        //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage(signedIn: true,)), (_) => false),
        //   fullNameInputController.clear(),
        //   emailInputController.clear(),
        //   pwdInputController.clear(),
        //   confirmPwdInputController.clear()
        // })
        //     .catchError((err) => print(err))
        // .catchError((err)=> print(err));

      }
    }else{
        showUserDialog(msgTitle: 'Error', msgText: "All fields are required to Register!", btnText: 'Close');
    }
  }

  saveUser() async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
      Firestore.instance
          .collection("users")
          .document(uid).setData({
      'id': uid,
      'profileName': fullNameInputController.text,
      'username': emailInputController.text,
      'url': '',
      'email': emailInputController.text,
      'bio': '',
      'timestamp': timeStamp,
      'isVip': false,
    }).whenComplete(() async => {
      await followersReference
          .document(uid)
          .collection('userFollowers')
          .document(uid)
          .setData({})
      });
  }

  showUserDialog({msgTitle, msgText, btnText, signFlag = false}){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text(msgTitle, style: TextStyle(color: Colors.red),),
        content: Text(msgText, style: TextStyle(color: Colors.white),),
        backgroundColor: AppColor.PageBgColorDark,
        actions: [
          FlatButton(
            color: Colors.white,
            child: Text(btnText, style: TextStyle(color: Colors.black),),
            onPressed: () {

              if(!signFlag){
                Navigator.of(context).pop();
              }else{
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (_) => false);
              }

            },
          )
        ],
      );
    });
  }

  askToSignIn() {
    fullNameInputController.clear();
    emailInputController.clear();
    pwdInputController.clear();
    confirmPwdInputController.clear();
    showUserDialog(msgTitle: 'Success', msgText: "Registration Successful. Please sign in with the credentials.", btnText: 'Ok', signFlag: true);

  }

  configureRealTimePushNotifications() async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    if (Platform.isIOS) {
      getIOSPermissions();
    }

    _firebaseMessaging.getToken().then((token) {
      usersReference
          .document(uid)
          .updateData({'androidNotificationToken': token});
    });

    _firebaseMessaging.configure(onMessage: (Map<String, dynamic> msg) async {
      final String recipientId = msg['data']['recipient'];
      final String body = msg['notification']['body'];

      if (recipientId == uid.toString()) {
        SnackBar snackBar = SnackBar(
          backgroundColor: Colors.grey,
          content: Text(
            body,
            style: TextStyle(
              color: Colors.black,
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
