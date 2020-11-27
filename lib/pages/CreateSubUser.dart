import 'dart:io';

import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/models/user.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:image/image.dart' as ImgDir;
import 'package:uuid/uuid.dart';

class CreateSubUser extends StatefulWidget {
  final User googleCurrentUser;

  CreateSubUser({this.googleCurrentUser});

  @override
  _CreateSubUserState createState() => _CreateSubUserState();
}

class _CreateSubUserState extends State<CreateSubUser> {
  File userImage;
  final picker = ImagePicker();
  bool uploading = false;
  bool userCreatedSuccess = false;
  String userId = Uuid().v4();
  int numberOfSubUsers = 0;
  String downloadUrlImage;

  TextEditingController usernameTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorWhite,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: colorBlack,
            ),
            onPressed: () {
              Navigator.pop(context);
            } //clearMemoryInfo,
            ),
        title: Text(
          'New User',
          style: TextStyle(
            color: colorBlack,
            fontFamily: 'Signatra',
            fontSize: 30.0,
          ),
        ),
        actions: [
          FlatButton(
            onPressed: uploading ? null : () => controlUploadAndSave(),
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: colorOffWhite,
      body: SafeArea(
        child: ListView(
          children: [
            InkWell(
              onTap: () => takeImage(context, 'userImage'),
              child: Container(
                height: 300,
                width: double.infinity,
                color: colorWhite,
                child: userImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image),
                          SizedBox(height: 5),
                          Text('Add Image'),
                        ],
                      )
                    : Image(
                        image: FileImage(userImage),
                        height: 160,
                        width: MediaQuery.of(context).size.width / 3 - 20,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 8, right: 8, top: 8),
              padding: EdgeInsets.only(left: 4, right: 4, top: 2),
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: colorBlack, fontSize: 16),
                autofocus: false,
                controller: usernameTextEditingController,
                decoration: InputDecoration(
                  icon: Icon(
                    Icons.rounded_corner,
                    color: colorBlack,
                  ),
                  hintText: 'Enter Name for Profile',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  takeImage(BuildContext mContext, String imageNumber) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              'Add Photo',
              style: TextStyle(
                color: colorWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              SimpleDialogOption(
                child: Text(
                  'Capture Image with Camera',
                  style: TextStyle(color: colorWhite),
                ),
                onPressed: () => captureImageWithCamera(imageNumber),
              ),
              SimpleDialogOption(
                child: Text(
                  'Select Image from Gallery',
                  style: TextStyle(color: colorWhite),
                ),
                onPressed: () => pickImageFromGallery(imageNumber),
              ),
              SimpleDialogOption(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colorWhite),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  captureImageWithCamera(String imageNumber) async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
      maxWidth: 680,
      maxHeight: 970,
    );

    setState(() {
      this.userImage = File(pickedFile.path);
    });
  }

  pickImageFromGallery(String imageNumber) async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      maxWidth: 680,
      maxHeight: 970,
    );

    setState(() {
      this.userImage = File(pickedFile.path);
    });
  }

  controlUploadAndSave() async {
    setState(() {
      uploading = true;
    });

    if (userImage == null || usernameTextEditingController.text.length < 3) {
      showPostAlert(
          postMsg: 'Can not Save as Photo or Username is not provided',
          msgType: true);
      uploading = false;
    } else {
      await compressingPhoto(userImage);
      downloadUrlImage = await uploadPhoto(userImage);

      if (downloadUrlImage == null) {
        print('Can not Save as Photo is not provided or Post not provided');
      } else if (downloadUrlImage == 'userlimit') {
        showPostAlert(
            postMsg: 'You are allowed to have 3 Memory users only.',
            msgType: true);
        uploading = false;
      } else {
        savePostInfoToFirestore(
            urlImage: downloadUrlImage,
            username: usernameTextEditingController.text);

        usernameTextEditingController.clear();

        setState(() {
          userImage = null;
          uploading = false;
          userId = Uuid().v4();
          userCreatedSuccess = true;
        });
      }
    }
  }

  compressingPhoto(File image) async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImgDir.Image mImageFile = ImgDir.decodeImage(image.readAsBytesSync());
    final compressedImageFile = File('$path/img_$userId.jpg')
      ..writeAsBytesSync(ImgDir.encodeJpg(mImageFile, quality: 60));
    setState(() {
      image = compressedImageFile;
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    if (numberOfSubUsers < 3) {
      StorageUploadTask mStorageUploadTask = memoryUserStorageReference
          .child('memoryuser_$userId.jpg')
          .putFile(mImageFile);
      StorageTaskSnapshot storageTaskSnapshot =
          await mStorageUploadTask.onComplete;
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } else {
      return 'userlimit';
    }
  }

  savePostInfoToFirestore({String urlImage, String username}) async {
    await getAllMemoryUsers();

    if (numberOfSubUsers < 3) {
      memoryUserReference
          .document(currentUser.id) //widget.googleCurrentUser.id)
          .collection('memoryUsers')
          .document(userId)
          .setData({
        'userId': userId,
        'ownerId': currentUser.id,
        'timestamp': DateTime.now(),
        'username': username,
        'url': urlImage,
      }).whenComplete(() => showPostAlert(
              postMsg: 'Your Memory User has been saved.', msgType: true));
    } else {
      showPostAlert(
          postMsg: 'You are allowed to have 3 Memory users only.',
          msgType: true);
    }
  }

  getAllMemoryUsers() async {
    QuerySnapshot querySnapshot = await memoryUserReference
        .document(currentUser.id)
        .collection('memoryUsers')
        .getDocuments();
    setState(() {
      numberOfSubUsers = querySnapshot.documents.length;
    });
  }

  showPostAlert({String postMsg, bool msgType = false}) {
    Alert(
      context: context,
      type: msgType ? AlertType.success : AlertType.error,
      style: AlertStyle(backgroundColor: colorWhite),
      title: "Memory",
      content: Text(
        msgType ? postMsg : 'Could not Create user. Try Again!',
        style: TextStyle(color: colorBlack, fontSize: 16),
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(color: colorWhite, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }
}
