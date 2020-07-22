import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/models/user.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String currentOnlineUserId;

  EditProfilePage({this.currentOnlineUserId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController profileNameTextEditingController =
      TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();

  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  User user;
  bool _bioValid = true;
  bool _profileNameValid = true;

  @override
  void initState() {
    super.initState();
    getDisplayAndUserInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        backgroundColor: colorBlack,
        iconTheme: IconThemeData(color: colorWhite),
        title: Text('Edit Profile', style: TextStyle(color: colorWhite)),
        actions: [
          IconButton(
            icon: Icon(Icons.done, color: colorWhite, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: loading
            ? circularProgress()
            : Card(
                elevation: 2,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 30,
                      child: Text(
                        'Been-a-Snap!',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                    ListView(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 16, bottom: 7),
                              child: CircleAvatar(
                                radius: 52,
                                backgroundImage:
                                    CachedNetworkImageProvider(user.url),
                              ),
                            ),
                            SizedBox(height: 20),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  createProfileNameTextFormField(),
                                  SizedBox(height: 20),
                                  createBioTextFormField(),
                                ],
                              ),
                            ),
                            SizedBox(height: 50),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                    onTap: logoutUser,
                                    child: Container(
                                      width: 120,
                                      height: 50,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: colorBlack,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.exit_to_app,
                                              color: Colors.red),
                                          SizedBox(width: 10),
                                          Text(
                                            'Logout',
                                            style: TextStyle(color: colorWhite),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: updateUserData,
                                    child: Container(
                                      width: 120,
                                      height: 50,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: colorBlack,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.save, color: Colors.green),
                                          SizedBox(width: 10),
                                          Text(
                                            'Save',
                                            style: TextStyle(color: colorWhite),
                                          ),
                                        ],
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
                  ],
                ),
              ),
      ),
    );
  }

  Column createProfileNameTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 13),
          child: Text(
            'Profile Name',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
        TextField(
          style: TextStyle(color: colorBlack),
          controller: profileNameTextEditingController,
          decoration: InputDecoration(
              hintText: 'Write Profile Name...',
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorGrey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorGrey),
              ),
              hintStyle: TextStyle(color: colorGrey),
              errorText:
                  _profileNameValid ? null : 'Profile name is very short'),
        ),
      ],
    );
  }

  Widget createBioTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            'Bio',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
        TextField(
          style: TextStyle(
            color: colorBlack,
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          controller: bioTextEditingController,
          maxLines: null,
          decoration: InputDecoration(
              hintText: 'Write Bio here...',
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorGrey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorGrey),
              ),
              hintStyle: TextStyle(color: colorGrey),
              errorText: _bioValid ? null : 'Bio is very long.'),
        ),
      ],
    );
  }

  updateUserData() {
    setState(() {
      profileNameTextEditingController.text.trim().length < 3 ||
              profileNameTextEditingController.text.isEmpty
          ? _profileNameValid = false
          : _profileNameValid = true;

      bioTextEditingController.text.trim().length > 110
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_bioValid && _profileNameValid) {
      usersReference.document(widget.currentOnlineUserId).updateData({
        'profileName': profileNameTextEditingController.text,
        'bio': bioTextEditingController.text,
      });
      SnackBar successSnackBar =
          SnackBar(content: Text('Profile has been updated successfully.'));
      _scaffoldGlobalKey.currentState.showSnackBar(successSnackBar);
    }
  }

  getDisplayAndUserInformation() async {
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot =
        await usersReference.document(widget.currentOnlineUserId).get();
    user = User.fromDocument(documentSnapshot);
    profileNameTextEditingController.text = user.profileName;
    bioTextEditingController.text = user.bio;

    setState(() {
      loading = false;
    });
  }

  logoutUser() async {
    await googleSignIn.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }
}
