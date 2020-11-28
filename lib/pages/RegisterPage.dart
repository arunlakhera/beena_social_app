import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/utilities/AppColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String fullName ='';
  String emailId ='';
  String password ='';
  String confirmPassword ='';

  @override
  Widget build(BuildContext context) {
    return buildRegisterScreen(context);
  }

  Widget buildRegisterScreen(context) {

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
                  child: TextField(
                    controller: fullNameController,
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
                    onChanged: (value){
                      setState(() {
                        fullName = fullNameController.text;
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
                    controller: passwordController,
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
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(5.0),
                  child: TextField(
                    controller: confirmPasswordController,
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
                    onChanged: (value){
                      setState(() {
                        confirmPassword = confirmPasswordController.text;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: (){
                    registerUser();
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
    );
  }

  void registerUser() {

    if(fullName == null){
      print('Full Name not provided');
    }else if(emailId == null){
      print('Email Id not provided');
    }else if(password == null){
      print('Password not provided');
    }else if(confirmPassword == null){
      print('Confirm Password not provided');
    }else if(password != confirmPassword){
      print('Password and Confirm Password does not match');
    }else{
      // Continue Sign up
    }
  }
}


