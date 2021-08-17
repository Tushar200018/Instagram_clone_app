import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'home.dart';

class Upload extends StatefulWidget {
  final User CurrentUser;

  Upload({this.CurrentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();

  @override
  void initState() {
    if (widget.CurrentUser != null) {
      print(widget.CurrentUser.displayName);
    } else {
      print("currentUser is null");
    }
    super.initState();
  }

  @override
  handleCameraPhoto() async {
    Navigator.pop(context);
    File photo_file = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    // print(photo_file.existsSync());
    setState(() {
      file = photo_file;
    });
  }

  handleGalleryPhoto() async {
    Navigator.pop(context);
    File gallery_file = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 675, maxWidth: 960);
    //  print(gallery_file.existsSync());
    setState(() {
      file = gallery_file;
    });
  }

  selectImage() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create Post"),
            children: [
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: handleCameraPhoto,
              ),
              SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleGalleryPhoto,
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/upload.svg",
            height: 250,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              onPressed: () {
                selectImage();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              color: Colors.deepOrange,
              child: Text(
                "Upload Image",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File("$path/img_$postId.jpg")
      ..writeAsBytes(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage() async {
    print("Before${file.existsSync()}");
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(file);
    print("After${file.existsSync()}");
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(String mediaUrl, String description, String location) {
    postsRef
        .document(widget.CurrentUser.id)
        .collection("user posts")
        .document(postId)
        .setData({
      "ownerId": widget.CurrentUser.id,
      "postId": postId,
      "username": widget.CurrentUser.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {}
    });
  }

  handlePostSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage();
    createPostInFirestore(
        mediaUrl, captionController.text, locationController.text);

    locationController.clear();
    captionController.clear();
    postId = Uuid().v4();
    setState(() {
      isUploading = false;
      file = null;
    });
  }

  buildUploadScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              file = null;
            });
          },
        ),
        title: Center(
          child: Text(
            "Caption Post",
            style: TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: TextButton(
              child: Center(
                child: Text(
                  "Post",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              onPressed: isUploading ? null : () => handlePostSubmit(),
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          isUploading ? linearProgress(context) : Text(""),
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(file), fit: BoxFit.cover)),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: ListTile(
              leading: widget.CurrentUser == null
                  ? null
                  : CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                          widget.CurrentUser.photoUrl),
                    ),
              title: Container(
                width: 250,
                child: TextFormField(
                  controller: captionController,
                  decoration: InputDecoration(
                      hintText: "Write a caption ...",
                      border: InputBorder.none),
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35,
            ),
            title: Container(
              width: 250,
              child: TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                    hintText: "Where the photo was taken ...",
                    border: InputBorder.none),
              ),
            ),
          ),
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              onPressed: () {
                getCurrentLocation();
              },
              icon: Icon(Icons.my_location, color: Colors.white),
              label: Text(
                "Get Current Location",
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  getCurrentLocation() async {
    Position position = await Geolocator().getCurrentPosition();
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String address = "${placemark.locality}, ${placemark.country}";
    locationController.text = address;
  }

  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    super.build(context);
    return file == null ? buildSplashScreen() : buildUploadScreen();
  }
}
