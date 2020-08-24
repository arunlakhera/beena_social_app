import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/models/user.dart';
import 'package:beena_social_app/pages/EditProfilePage.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/widgets/HeaderWidget.dart';
import 'package:beena_social_app/widgets/PostTileWidget.dart';
import 'package:beena_social_app/widgets/PostWidget.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;

  ProfilePage({this.userProfileId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentUser?.id;
  bool loading = false;
  int countPost = 0;
  List<Post> postsList = [];
  String postOrientation = 'grid';
  int countTotalFollowers = 0;
  int countTotalFollowings = 0;
  bool following = false;
  var totalPosts = 0;
  var totalFollowers = 0;
  var totalFollowing = 0;
  bool ownProfile = false;

  @override
  void initState() {
    super.initState();
    getAllProfilePosts();
    getAllFollowers();
    getAllFollowings();
    checkIfAlreadyFollowing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      appBar: header(context, strTitle: 'Profile'),
      body: SafeArea(
        child: ListView(
          children: [
            createProfileTopView(),
            createListAndGridPostOrientation(),
            Divider(),
            displayProfilePost(),
          ],
        ),
      ),
    );
  }

  createProfileTopView() {
    ownProfile = (currentOnlineUserId == widget.userProfileId);
    return FutureBuilder(
      future: usersReference.document(widget.userProfileId).get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }

        User user = User.fromDocument(dataSnapshot.data);

        return Column(
          children: [
            Card(
              elevation: 3,
              color: colorWhite,
              child: Container(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          decoration: BoxDecoration(
                            color: user.isVip
                                ? Colors.yellow.shade900
                                : Colors.white,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: user.url,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) {
                              return Shimmer.fromColors(
                                child: Container(height: 80),
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                loop: 5,
                              );
                            },
                            errorWidget: (context, url, error) => Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                  Text(
                                    'Could not load Image...',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.profileName.toUpperCase(),
                                style: TextStyle(
                                  color: colorBlack,
                                  fontSize: 18,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                user.username,
                                style: TextStyle(
                                  color: colorBlack,
                                  fontSize: 15,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10),
                              Visibility(
                                visible: user.isVip ? true : false,
                                child: Row(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.starOfLife,
                                      size: 12,
                                      color: Colors.yellow.shade900,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'VIP',
                                      style: TextStyle(
                                          color: Colors.yellow.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          letterSpacing: 1),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ownProfile
                            ? IconButton(
                                onPressed: () => editUserProfile(),
                                icon: FaIcon(
                                  FontAwesomeIcons.edit,
                                  color: colorBlack,
                                ),
                              )
                            : Text(''),
                      ],
                    ),
                    SizedBox(height: 10),
                    user.bio.trim().length > 1
                        ? Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(top: 3),
                            child: Text(
                              user.bio,
                              style: TextStyle(
                                color: colorBlack,
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          )
                        : Text(''),
                    SizedBox(height: 10),
                    ownProfile
                        ? Text('')
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createButton(),
                            ],
                          ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 3,
              color: colorWhite,
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    createColumns(title: 'Posts', count: countPost),
                    createColumns(
                        title: 'Followers', count: countTotalFollowers),
                    createColumns(
                        title: 'Following', count: countTotalFollowings),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Column createColumns({String title, int count}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          NumberFormat.compact().format(count).toString(),
          style: TextStyle(
              fontSize: 20,
              color: colorBlack,
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand'),
        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  createButton() {
    ownProfile = (currentOnlineUserId == widget.userProfileId);
    if (following && !ownProfile) {
      return createButtonTitleAndFunction(
        title: 'Unfollow',
        performFunction: controlUnfollowUser,
      );
    } else if (!following && !ownProfile) {
      return createButtonTitleAndFunction(
        title: 'Follow',
        performFunction: controlFollowUser,
      );
    } else {
      return Text('');
    }
  }

  createButtonTitleAndFunction({String title, Function performFunction}) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: following ? colorGrey : colorBlack,
        border: Border.all(color: colorGrey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: FlatButton(
        onPressed: performFunction,
        child: Text(
          title,
          style: TextStyle(
            color: following ? colorWhite : colorWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  editUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            //EditProfilePage(currentOnlineUserId: currentOnlineUserId),
            EditProfilePage(),
      ),
    );
  }

  displayProfilePost() {
    if (loading) {
      return linearProgress();
    } else if (postsList.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(30),
              child: Icon(
                Icons.photo_library,
                color: colorGrey,
                size: 200,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'No Posts',
                style: TextStyle(
                    color: colorBlack,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == 'grid') {
      loading = false;
      if (loading) {
        loading = false;
      }
      linearProgress();
      List<GridTile> gridTilesList = [];
      postsList.forEach((eachPost) {
        gridTilesList.add(GridTile(child: PostTile(post: eachPost)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTilesList,
      );
    } else if (postOrientation == 'list') {
      return Column(
        children: postsList,
      );
    }
  }

  getAllProfilePosts() async {
    setState(() {
      loading = true;
    });
    QuerySnapshot querySnapshot = await postsReference
        .document(widget.userProfileId)
        .collection('usersPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    setState(() {
      loading = false;
      countPost = querySnapshot.documents.length;
      postsList = querySnapshot.documents
          .map((documentSnapshot) => Post.fromDocument(documentSnapshot))
          .toList();
    });
  }

  createListAndGridPostOrientation() {
    return Card(
      elevation: 3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FlatButton.icon(
              onPressed: () => setOrientation('grid'),
              icon: Icon(
                Icons.grid_on,
                color: postOrientation == 'grid'
                    ? Theme.of(context).primaryColor
                    : colorGrey,
              ),
              label: Text('')),
          FlatButton.icon(
              onPressed: () => setOrientation('list'),
              icon: Icon(
                Icons.list,
                color: postOrientation == 'list'
                    ? Theme.of(context).primaryColor
                    : colorGrey,
              ),
              label: Text('')),
        ],
      ),
    );
  }

  setOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }

  controlUnfollowUser() {
    setState(() {
      following = false;
    });
    followersReference
        .document(widget.userProfileId)
        .collection('userFollowers')
        .document(currentOnlineUserId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    followingReference
        .document(currentOnlineUserId)
        .collection('userFollowing')
        .document(widget.userProfileId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    activityFeedReference
        .document(widget.userProfileId)
        .collection('feedItems')
        .document(currentOnlineUserId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
  }

  controlFollowUser() {
    setState(() {
      following = true;
    });

    followersReference
        .document(widget.userProfileId)
        .collection('userFollowers')
        .document(currentOnlineUserId)
        .setData({});

    followingReference
        .document(currentOnlineUserId)
        .collection('userFollowing')
        .document(widget.userProfileId)
        .setData({});

    activityFeedReference
        .document(widget.userProfileId)
        .collection('feedItems')
        .document(currentOnlineUserId)
        .setData({
      'type': 'follow',
      'ownerId': widget.userProfileId,
      'username': currentUser.username,
      'timestamp': DateTime.now(),
      'userProfileImg': currentUser.url,
      'userId': currentOnlineUserId,
    });
  }

  checkIfAlreadyFollowing() async {
    DocumentSnapshot documentSnapshot = await followersReference
        .document(widget.userProfileId)
        .collection('userFollowers')
        .document(currentOnlineUserId)
        .get();
    setState(() {
      following = documentSnapshot.exists;
    });
  }

  getAllFollowers() async {
    QuerySnapshot querySnapshot = await followersReference
        .document(widget.userProfileId)
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      if (querySnapshot.documents.length > 0) {
        countTotalFollowers = querySnapshot.documents.length - 1;
      } else {
        countTotalFollowers = 0;
      }
    });
  }

  getAllFollowings() async {
    QuerySnapshot querySnapshot = await followingReference
        .document(widget.userProfileId)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      countTotalFollowings = querySnapshot.documents.length;
    });
  }
}
