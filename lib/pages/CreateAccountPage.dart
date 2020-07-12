import 'dart:async';
import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/widgets/HeaderWidget.dart';
import 'package:flutter/material.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  String username;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(
        context,
        strTitle: 'Settings',
        hideBackButton: true,
      ),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: Center(
                    child: Text(
                      'Set up a username',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: TextFormField(
                        style: TextStyle(color: colorWhite),
                        validator: (val) {
                          if (val.isEmpty || val.length < 5) {
                            return 'username is too short';
                          } else if (val.length > 20) {
                            return 'username is too long';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) => username = value,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: colorGrey)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: colorWhite)),
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                          labelStyle: TextStyle(fontSize: 16),
                          hintText: 'must bt at least 5 characters.',
                          hintStyle: TextStyle(color: colorGrey),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submitUserName,
                  child: Container(
                    height: 55,
                    width: 360,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Proceed',
                        style: TextStyle(
                          color: colorWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void submitUserName() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      SnackBar snackBar = SnackBar(
        content: Text('Welcome $username'),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 4), () {
        Navigator.pop(context, username);
      });
    }
  }
}
