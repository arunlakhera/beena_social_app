import 'dart:io';

import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/models/user.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImgDir;

class UploadPage extends StatefulWidget {
  final User googleCurrentUser;

  UploadPage({this.googleCurrentUser});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with AutomaticKeepAliveClientMixin<UploadPage> {
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  File image;
  final picker = ImagePicker();
  bool uploading = false;
  String postId = Uuid().v4();
  bool postUploadSuccess = false;

  TextEditingController descriptionTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return image == null ? displayUploadScreen() : displayUploadFormScreen();
  }

  Widget displayUploadScreen() {
    return Container(
      color: colorWhite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            color: colorGrey,
            size: 200,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                'Upload Image',
                style: TextStyle(
                  color: colorWhite,
                  fontSize: 20,
                ),
              ),
              color: Colors.black,
              onPressed: () => takeImage(context),
            ),
          ),
        ],
      ),
    );
  }

  takeImage(BuildContext mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              'New Post',
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
                onPressed: captureImageWithCamera,
              ),
              SimpleDialogOption(
                child: Text(
                  'Select Image from Gallery',
                  style: TextStyle(color: colorWhite),
                ),
                onPressed: pickImageFromGallery,
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

  captureImageWithCamera() async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
      maxWidth: 680,
      maxHeight: 970,
    );
    setState(() {
      this.image = File(pickedFile.path);
    });
  }

  pickImageFromGallery() async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    setState(() {
      this.image = File(pickedFile.path);
    });
  }

  displayUploadFormScreen() {
    return Scaffold(
      key: _scaffoldGlobalKey,
      backgroundColor: colorWhite,
      appBar: AppBar(
        backgroundColor: colorWhite,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: colorBlack,
            ),
            onPressed: clearPostInfo),
        title: Text(
          'New Post',
          style: TextStyle(
            color: colorBlack,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          FlatButton(
            onPressed: uploading ? null : () => controlUploadAndSave(),
            child: Text(
              'Share',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          uploading ? linearProgress() : Text(''),
          Container(
            height: 230,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 12)),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.googleCurrentUser.url),
            ),
            title: Container(
              width: 250,
              child: TextField(
                style: TextStyle(color: colorBlack),
                controller: descriptionTextEditingController,
                decoration: InputDecoration(
                  hintText: 'Say Something about your image',
                  hintStyle: TextStyle(color: colorBlack),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.person_pin_circle,
              color: colorBlack,
              size: 36,
            ),
            title: Container(
              width: 250,
              child: TextField(
                style: TextStyle(color: colorBlack),
                controller: locationTextEditingController,
                decoration: InputDecoration(
                  hintText: 'My Location',
                  hintStyle: TextStyle(color: colorBlack),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          Container(
            width: 220,
            height: 110,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35),
              ),
              color: colorBlack,
              icon: Icon(
                Icons.location_on,
                color: colorWhite,
              ),
              label: Text(
                'Get my Current Location',
                style: TextStyle(
                  color: colorWhite,
                ),
              ),
              onPressed: getUserCurrentLocation,
            ),
          ),
        ],
      ),
    );
  }

  clearPostInfo() {
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    setState(() {
      image = null;
    });
  }

  getUserCurrentLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placeMarks[0];
    //String completeAddressInfo =
    //  '${placemark.subThoroughfare} ${placemark.thoroughfare},${placemark.subLocality} ${placemark.locality},${placemark.subAdministrativeArea} ${placemark.administrativeArea},${placemark.postalCode} ${placemark.country}';
    String specificAddress = '${placemark.locality}, ${placemark.country}';
    locationTextEditingController.text = specificAddress;
  }

  controlUploadAndSave() async {
    setState(() {
      uploading = true;
    });
    await compressingPhoto();

    String downloadUrl = await uploadPhoto(image);
    if (downloadUrl == null && locationTextEditingController.text == null) {
      print('Can not Save as Photo is not provided or Post not provided');
    } else {
      savePostInfoToFirestore(
          url: downloadUrl,
          location: locationTextEditingController.text,
          description: descriptionTextEditingController.text);

      locationTextEditingController.clear();
      descriptionTextEditingController.clear();

      setState(() {
        image = null;
        uploading = false;
        postId = Uuid().v4();
        postUploadSuccess = true;
      });
    }
  }

  compressingPhoto() async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImgDir.Image mImageFile = ImgDir.decodeImage(image.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(ImgDir.encodeJpg(mImageFile, quality: 60));
    setState(() {
      image = compressedImageFile;
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    StorageUploadTask mStorageUploadTask =
        storageReference.child('post_$postId.jpg').putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await mStorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  savePostInfoToFirestore({String url, String location, String description}) {
    postsReference
        .document(widget.googleCurrentUser.id)
        .collection('usersPosts')
        .document(postId)
        .setData({
      'postId': postId,
      'ownerId': widget.googleCurrentUser.id,
      'timestamp': DateTime.now(),
      'likes': {},
      'username': widget.googleCurrentUser.username,
      'description': description,
      'location': location,
      'url': url,
    }).whenComplete(() => showPostAlert(
            postMsg: 'Your Post has been published.', msgType: true));
  }

  showPostAlert({String postMsg, bool msgType = false}) {
    Alert(
      context: context,
      type: msgType ? AlertType.success : AlertType.error,
      style: AlertStyle(backgroundColor: colorWhite),
      title: "Post",
      content: Text(
        msgType ? postMsg : 'Could not Post. Try Again!',
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
