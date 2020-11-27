import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/pages/CreateMemory.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/widgets/HeaderWidget.dart';
import 'package:beena_social_app/widgets/MemoryTileWidget.dart';
import 'package:beena_social_app/widgets/MemoryWidget.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserMemoryPage extends StatefulWidget {
  final String currentUserId;
  final String subUserId;
  final String userName;
  final String imageUrl;

  UserMemoryPage(
      {this.currentUserId, this.subUserId, this.userName, this.imageUrl});

  @override
  _UserMemoryPageState createState() =>
      _UserMemoryPageState(currentUserId, subUserId, userName, imageUrl);
}

class _UserMemoryPageState extends State<UserMemoryPage> {
  final String currentUserId;
  final String subUserId;
  final String userName;
  final String imageUrl;

  String postOrientation = 'grid';
  bool loading = false;
  List<Memory> memoriesList = [];

  _UserMemoryPageState(
      this.currentUserId, this.subUserId, this.userName, this.imageUrl);

  @override
  void initState() {
    super.initState();
    getAllProfileMemories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorOffWhite,
      appBar: header(context,
          isAppTitle: false, strTitle: userName, hideBackButton: false),
      body: RefreshIndicator(
        onRefresh: () => getAllProfileMemories(),
        child: SafeArea(
          child: ListView(
            children: [
              createTopView(),
              createListAndGridPostOrientation(),
              displayProfileMemories(),
            ],
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: currentUserId == currentUser.id ? true : false,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CreateMemory(userId: currentUser.id, subUserId: subUserId);
            }));
          },
          child: Icon(
            Icons.add,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  createTopView() {
    return Container(
      alignment: Alignment.bottomCenter,
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(imageUrl),
        ),
      ),
      child: Container(
        width: double.infinity,
        color: Colors.grey,
        child: Text(
          userName,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: colorOffWhite,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontFamily: 'Quicksand'),
        ),
      ),
    );
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

  displayProfileMemories() {
    if (loading) {
      return linearProgress();
    } else if (memoriesList.isEmpty) {
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
                'No Memories',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
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
      memoriesList.forEach((eachMemory) {
        gridTilesList.add(GridTile(child: MemoryTile(memory: eachMemory)));
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
        children: memoriesList,
      );
    }
  }

  getAllProfileMemories() async {
    setState(() {
      loading = true;
    });
    QuerySnapshot querySnapshot = await memoryReference
        .document(currentUserId)
        .collection('users')
        .document(subUserId)
        .collection('usersMemory')
        .getDocuments();

    setState(() {
      loading = false;

      memoriesList = querySnapshot.documents
          .map((documentSnapshot) => Memory.fromDocument(documentSnapshot))
          .toList();
    });
  }
}
