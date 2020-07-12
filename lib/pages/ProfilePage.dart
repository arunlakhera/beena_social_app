import 'package:beena_social_app/widgets/HeaderWidget.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: 'Profile'),
      body: SafeArea(
        child: Text(
          "Profile Page goes here.",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
