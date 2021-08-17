import 'package:cached_network_image/cached_network_image.dart';
import "package:flutter/material.dart";
import 'package:fluttershare/models/user.dart';
import 'home.dart';

class EditProfile extends StatefulWidget {
  Function logout;
  EditProfile({this.logout});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  final displayNameformKey = GlobalKey<FormState>();
  final bioformKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    displayNameController.text = currentUser.displayName;
    bioController.text = currentUser.bio;
    super.initState();
  }

  buildDisplayTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Text(
            "Display Name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Form(
          autovalidateMode: AutovalidateMode.always,
          key: displayNameformKey,
          child: TextFormField(
            validator: (value) {
              if (value.trim().length < 5) {
                return "Display Name too short";
              } else {
                return null;
              }
            },
            controller: displayNameController,
            decoration: InputDecoration(hintText: "Update Display Name"),
          ),
        )
      ],
    );
  }

  buildBioTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Form(
          autovalidateMode: AutovalidateMode.always,
          key: bioformKey,
          child: TextFormField(
            validator: (value) {
              if (value.trim().length > 100) {
                return "Bio too long";
              } else {
                return null;
              }
            },
            controller: bioController,
            decoration: InputDecoration(hintText: "Update Bio"),
          ),
        )
      ],
    );
  }

  updateProfile() {
    if (displayNameformKey.currentState.validate() &&
        bioformKey.currentState.validate()) {
      usersRef.document(currentUser.id).updateData({
        "displayName": displayNameController.text,
        "bio": bioController.text
      });
      SnackBar snackBar = SnackBar(
        content: Text("Profile Updated!"),
      );
      scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  signout() async {
    await widget.logout();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "Edit Profile",
            style: TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.done,
                color: Colors.green,
                size: 30,
              ))
        ],
      ),
      body: ListView(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 8),
              child: CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(currentUser.photoUrl),
                backgroundColor: Colors.grey,
                radius: 50,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                  children: [buildDisplayTextField(), buildBioTextField()]),
            ),
            GestureDetector(
              onTap: updateProfile,
              child: Container(
                margin: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                padding: EdgeInsets.all(10),
                child: Text(
                  "Update Profile",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextButton.icon(
                onPressed: signout,
                icon: Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                label: Text(
                  "Logout",
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
              ),
            )
          ],
        ),
      ]),
    );
  }
}
