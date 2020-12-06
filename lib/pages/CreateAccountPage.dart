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
      backgroundColor: colorWhite,
      appBar: header(
        context,
        strTitle: 'Settings',
        hideBackButton: true,
      ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Text(
              'Beena',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                fontFamily: 'Signatra',
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
          ),
          ListView(
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
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        autovalidate: true,
                        child: TextFormField(
                          style: TextStyle(color: colorBlack),
                          validator: (val) {
                            if (val.isEmpty || val.length < 5) {
                              return 'Username is too short';
                            } else if (val.length > 20) {
                              return 'Username is too long';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) => username = value,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: colorGrey)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: Colors.green)),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: Colors.green)),
                            labelText: 'Username',
                            labelStyle: TextStyle(fontSize: 16),
                            hintText: 'must bt at least 5 characters.',
                            hintStyle: TextStyle(color: colorGrey),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: submitUserName,
                      child: Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width / 2,
                        decoration: BoxDecoration(
                          color: colorBlack,
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
        ],
      ),
    );
  }

  void submitUserName() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      SnackBar snackBar = SnackBar(content: Text('Welcome $username'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 4), () {
        Navigator.pop(context, username);
      });
    }
  }
}
