import 'dart:io';
import 'dart:async';
import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/models/user.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as ImgDir;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:audioplayers/audioplayers.dart';

class CreateMemory extends StatefulWidget {
  final User googleCurrentUser;

  CreateMemory({this.googleCurrentUser});
  @override
  _CreateMemoryState createState() => _CreateMemoryState();
}

class _CreateMemoryState extends State<CreateMemory>
    with AutomaticKeepAliveClientMixin<CreateMemory> {
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  File image1;
  File image2;
  File image3;
  File recMessage;

  final picker = ImagePicker();
  bool uploading = false;
  String memoryId = Uuid().v4();
  bool postUploadSuccess = false;

  TextEditingController descriptionTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  String statusText = "Record your message.";
  String statusSec = "30 s";
  bool isComplete = false;
  String recordFilePath;

  int i = 0;
  bool isRecording = false;
  bool isPlaying = false;

  int currentDuration = 0;
  String currentRecordingDuration = '0 s';

  Timer _timer;
  int _start = 0;

  void startTimer(int start) {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start >= 30) {
            timer.cancel();
            stopRecord();
          } else {
            _start = _start + 1;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalKey,
      backgroundColor: colorOffWhite,
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
          'New Memory',
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
      body: uploading
          ? circularProgress()
          : ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 8.0, bottom: 4.0),
                  child: Column(
                    children: [
                      Card(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => takeImage(context, 'image1'),
                              child: Container(
                                alignment: Alignment.center,
                                height: 170,
                                width:
                                    MediaQuery.of(context).size.width / 3 - 10,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: image1 == null
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            size: 30,
                                            color: Colors.black,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Add Photo',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      )
                                    : Image(
                                        image: FileImage(image1),
                                        height: 160,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    3 -
                                                20,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            image1 == null
                                ? Container()
                                : InkWell(
                                    onTap: () => takeImage(context, 'image2'),
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 170,
                                      width: MediaQuery.of(context).size.width /
                                              3 -
                                          10,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: image2 == null
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add,
                                                  size: 30,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  'Add Photo',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            )
                                          : Image(
                                              image: FileImage(image2),
                                              height: 160,
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3 -
                                                  20,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                            (image2 == null)
                                ? Container()
                                : InkWell(
                                    onTap: () => takeImage(context, 'image3'),
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 170,
                                      width: MediaQuery.of(context).size.width /
                                              3 -
                                          10,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: image3 == null
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add,
                                                  size: 30,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  'Add Photo',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            )
                                          : Image(
                                              image: FileImage(image3),
                                              height: 160,
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3 -
                                                  20,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      Divider(),
                      Card(
                        child: ListTile(
                          tileColor: colorWhite,
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                                widget.googleCurrentUser.url),
                          ),
                          title: Container(
                            width: 250,
                            height: 200,
                            child: TextField(
                              maxLines: 10,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(color: colorBlack),
                              controller: descriptionTextEditingController,
                              decoration: InputDecoration(
                                hintText: 'Say Something about your image',
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade600),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Divider(),
                      Card(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    if (!isRecording) {
                                      startRecord();
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Icon(Icons.mic, size: 25),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    stopRecord();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Icon(Icons.stop, size: 25),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (isComplete &&
                                        recordFilePath != null &&
                                        !isPlaying) {
                                      play();
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Icon(
                                      Icons.arrow_right,
                                      size: 25,
                                      color:
                                          isComplete && recordFilePath != null
                                              ? Colors.black
                                              : Colors.grey,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 10),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: isComplete
                                                  ? '$currentRecordingDuration \/ '
                                                  : '$_start s \/ ',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                            TextSpan(
                                              text: '30 s',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      Card(
                        child: ListTile(
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
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade600),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Divider(),
                      Container(
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
                ),
              ],
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
      if (imageNumber == 'image1') {
        this.image1 = File(pickedFile.path);
      } else if (imageNumber == 'image2') {
        this.image2 = File(pickedFile.path);
      } else if (imageNumber == 'image3') {
        this.image3 = File(pickedFile.path);
      }
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
      if (imageNumber == 'image1') {
        this.image1 = File(pickedFile.path);
      } else if (imageNumber == 'image2') {
        this.image2 = File(pickedFile.path);
      } else if (imageNumber == 'image3') {
        this.image3 = File(pickedFile.path);
      }
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

    if (image1 == null) {
      showPostAlert(
          postMsg: 'Can not Save as Photo is not provided', msgType: true);
      uploading = false;
    } else {
      await compressingPhoto(image1, 'img1');
      String downloadUrlImage1 = await uploadPhoto(image1, 'img1');

      String downloadUrlImage2;
      if (image2 != null) {
        await compressingPhoto(image2, 'img2');
        downloadUrlImage2 = await uploadPhoto(image2, 'img2');
      } else {
        downloadUrlImage2 = 'NA';
      }

      String downloadUrlImage3;
      if (image3 != null) {
        await compressingPhoto(image3, 'img3');
        downloadUrlImage3 = await uploadPhoto(image3, 'img3');
      } else {
        downloadUrlImage3 = 'NA';
      }

      String downloadRecordingUrl;

      if (recordFilePath != null && File(recordFilePath).existsSync()) {
        downloadRecordingUrl = await uploadRecording(recordFilePath);
      } else {
        downloadRecordingUrl = 'NA';
      }

      if (downloadUrlImage1 == null &&
          locationTextEditingController.text == null) {
        print('Can not Save as Photo is not provided or Post not provided');
      } else {
        savePostInfoToFirestore(
            urlImage1: downloadUrlImage1,
            urlImage2: downloadUrlImage2,
            urlImage3: downloadUrlImage3,
            urlRecording: downloadRecordingUrl,
            location: locationTextEditingController.text,
            description: descriptionTextEditingController.text);

        locationTextEditingController.clear();
        descriptionTextEditingController.clear();

        setState(() {
          image1 = null;
          image2 = null;
          image3 = null;
          recordFilePath = null;
          recMessage = null;
          _start = 0;
          currentDuration = 0;
          currentRecordingDuration = '0 s';
          uploading = false;
          memoryId = Uuid().v4();
          postUploadSuccess = true;
        });
      }
    }
  }

  compressingPhoto(File image, String imgNum) async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImgDir.Image mImageFile = ImgDir.decodeImage(image.readAsBytesSync());
    final compressedImageFile = File('$path/img_$memoryId-$imgNum.jpg')
      ..writeAsBytesSync(ImgDir.encodeJpg(mImageFile, quality: 60));
    setState(() {
      image = compressedImageFile;
    });
  }

  Future<String> uploadPhoto(mImageFile, String imgNum) async {
    StorageUploadTask mStorageUploadTask = memoryStorageReference
        .child('memory_$memoryId-$imgNum.jpg')
        .putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await mStorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadRecording(mrecordFile) async {
    File recFile = File(mrecordFile);
    StorageUploadTask mStorageUploadTask = recordingStorageReference
        .child('memory_rec_$memoryId.mp3')
        .putFile(recFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await mStorageUploadTask.onComplete;
    String downloadRecordingUrl =
        await storageTaskSnapshot.ref.getDownloadURL();
    return downloadRecordingUrl;
  }

  savePostInfoToFirestore(
      {String urlImage1,
      String urlImage2,
      String urlImage3,
      String urlRecording,
      String location,
      String description}) {
    memoryReference
        .document(widget.googleCurrentUser.id)
        .collection('usersMemory')
        .document(memoryId)
        .setData({
      'memoryId': memoryId,
      'ownerId': widget.googleCurrentUser.id,
      'timestamp': DateTime.now(),
      'likes': {},
      'username': widget.googleCurrentUser.username,
      'description': description,
      'location': location,
      'urlImage1': urlImage1,
      'urlImage2': urlImage2,
      'urlImage3': urlImage3,
      'urlRecording': urlRecording,
    }).whenComplete(() => showPostAlert(
            postMsg: 'Your Memory Post has been published.', msgType: true));
  }

  showPostAlert({String postMsg, bool msgType = false}) {
    Alert(
      context: context,
      type: msgType ? AlertType.success : AlertType.error,
      style: AlertStyle(backgroundColor: colorWhite),
      title: "Memory",
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

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      startTimer(_start);
      isRecording = true;
      statusText = "Recording...";
      recordFilePath = await getFilePath();

      isComplete = false;
      RecordMp3.instance.start(recordFilePath, (type) {
        statusText = "Record error--->$type";
        setState(() {});
      });
    } else {
      statusText = "No microphone permission";
    }
    setState(() {});
  }

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);

    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/test_${i++}.mp3";
  }

  void stopRecord() {
    bool s = RecordMp3.instance.stop();
    if (s) {
      _timer.cancel();
      isRecording = false;
      _start = 0;
      statusText = "Recording completed";
      isComplete = true;

      setState(() {});
    }
  }

  void play() {
    if (recordFilePath != null && File(recordFilePath).existsSync()) {
      AudioPlayer audioPlayer = AudioPlayer();
      audioPlayer.play(recordFilePath, isLocal: true);
      statusText = 'Playing...';
      isPlaying = true;

      audioPlayer.onPlayerCompletion.listen((event) {
        setState(() {
          isPlaying = false;
          statusText = 'Play again.';
        });
      });

      audioPlayer.onAudioPositionChanged.listen((Duration cDuration) {
        currentDuration = cDuration.inSeconds.toInt();
      });

      audioPlayer.onDurationChanged.listen((Duration d) {
        setState(() {
          currentRecordingDuration = '$currentDuration s';
        });
      });
    }
  }
}
