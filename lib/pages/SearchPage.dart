import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/models/user.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/pages/ProfilePage.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBlack,
      appBar: searchPageHeader(),
      body: futureSearchResults == null
          ? displayNoSearchResultScreen()
          : displayUsersFoundScreen(),
    );
  }

  AppBar searchPageHeader() {
    return AppBar(
      backgroundColor: colorBlack,
      title: TextFormField(
        style: TextStyle(
          fontSize: 20,
          color: colorWhite,
        ),
        controller: searchTextEditingController,
        decoration: InputDecoration(
          hintText: 'Search here...',
          hintStyle: TextStyle(color: colorGrey),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colorGrey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colorWhite),
          ),
          filled: true,
          prefixIcon: Icon(
            Icons.person,
            color: colorWhite,
            size: 30,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.clear,
              color: colorWhite,
            ),
            onPressed: clearSearchTextField,
          ),
        ),
        onFieldSubmitted: controlSearching,
      ),
    );
  }

  void clearSearchTextField() {
    searchTextEditingController.clear();
  }

  void controlSearching(String searchUser) {
    Future<QuerySnapshot> allUsers = usersReference
        .where('profileName', isGreaterThanOrEqualTo: searchUser)
        .getDocuments();
    setState(() {
      futureSearchResults = allUsers;
    });
  }

  displayNoSearchResultScreen() {
    //final Orientation orientation = MediaQuery.of(context).orientation;
    return Center(
      child: Container(
        child: ListView(
          shrinkWrap: true,
          children: [
            Icon(
              Icons.group,
              color: colorGrey,
              size: 200,
            ),
            Text(
              'Search Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorWhite,
                fontWeight: FontWeight.w500,
                fontSize: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  displayUsersFoundScreen() {
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }

        List<UserResult> searchUsersResult = [];
        dataSnapshot.data.documents.forEach((document) {
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser: eachUser);
          searchUsersResult.add(userResult);
        });
        return ListView(
          children: searchUsersResult,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class UserResult extends StatelessWidget {
  final User eachUser;

  UserResult({this.eachUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: Container(
        color: Colors.white54,
        child: Column(
          children: [
            GestureDetector(
              onTap: () => displayUserProfile(
                context,
                userProfileId: eachUser.id,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorBlack,
                  backgroundImage: CachedNetworkImageProvider(eachUser.url),
                ),
                title: Text(
                  eachUser.profileName,
                  style: TextStyle(
                    color: colorBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  eachUser.username,
                  style: TextStyle(
                    color: colorBlack,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  displayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(userProfileId: userProfileId)));
  }
}
