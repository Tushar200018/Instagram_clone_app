import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final usersRef = Firestore.instance.collection("users");
final StorageReference storageRef = FirebaseStorage.instance.ref();
final postsRef = Firestore.instance.collection("posts");
final commentsRef = Firestore.instance.collection("comments");
final activityFeedRef = Firestore.instance.collection("feed");
final followersRef = Firestore.instance.collection("followers");
final followingRef = Firestore.instance.collection("following");
final timelineRef = Firestore.instance.collection("timeline");
final auth = FirebaseAuth.instance;

User currentUser;
GoogleSignIn googleSignIn = GoogleSignIn();
final DateTime timestamp = DateTime.now();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool is_Auth = false;
  PageController page_controller;
  TabController tab_controller;
  int page_index = 0;
  String idToken;
  String accessToken;
  FirebaseUser firebaseUser;
  User testUser = User(displayName: "test");

  @override
  void initState() {
    page_controller = PageController(initialPage: 0);
    tab_controller = TabController(length: 5, vsync: this);

    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print("Print error signing in: $err");
    });

    googleSignIn
        .signInSilently(suppressErrors: false)
        .then((account) => handleSignIn(account))
        .catchError((err) {
      print("Error signing in: $err");
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    page_controller.dispose();
    tab_controller.dispose();
  }

  FirebaseAuthSignIn() async {
    // account.authentication.then((GoogleKey) {
    //   idToken = GoogleKey.idToken;
    //   accessToken = GoogleKey.accessToken;
    // });

    // print("idToke = $idToken");
    // print("accessToken = $accessToken");

    try {
      // final AuthCredential credential = GoogleAuthProvider.getCredential(
      //     idToken: idToken, accessToken: accessToken);
      firebaseUser = await auth.signInAnonymously();
      print(firebaseUser.uid);
    } catch (error) {
      print(error);
      if (firebaseUser == null) {
        FirebaseAuthSignIn();
      }
    }
  }

  void handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await FirebaseAuthSignIn();
      await CreateAccountInFirestore();

      setState(() {
        is_Auth = true;
      });
    } else {
      setState(() {
        print("false");
        is_Auth = false;
      });
    }
  }

  CreateAccountInFirestore() async {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    if (!doc.exists) {
      String username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      usersRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });

      followersRef
          .document(user.id)
          .collection("userFollowers")
          .document(user.id)
          .setData({});

      // auth.createUserWithEmailAndPassword(email: user.email, password: user.id);

    }
    doc = await usersRef.document(user.id).get();
    setState(() {
      currentUser = User.fromDocument(doc);
    });

    if (currentUser != null) {
      print(currentUser.username);
    }
  }

  void login() {
    googleSignIn.signIn();
  }

  void logout() {
    googleSignIn.signOut();
    auth.signOut();
  }

  Scaffold auth_screen() {
    return Scaffold(
      body: PageView(
        children: [
          Timeline(),
          // RaisedButton(
          //   onPressed: logout,
          //   child: Text("Log Out"),
          // ),
          ActivityFeed(),
          Upload(CurrentUser: currentUser == null ? testUser : currentUser),
          Search(),
          Profile(profileId: currentUser.id)
        ],
        controller: page_controller,
        onPageChanged: (index) {
          page_index = index;
          tab_controller.animateTo(page_index,
              duration: Duration(milliseconds: 200), curve: Curves.bounceInOut);
        },
      ),
      bottomNavigationBar: TabBar(
        indicatorColor: Theme.of(context).primaryColor,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey.shade600,
        controller: tab_controller,
        onTap: (index) {
          page_controller.animateToPage(index,
              duration: Duration(milliseconds: 200), curve: Curves.bounceInOut);
        },
        tabs: [
          Tab(
              icon: Icon(
            Icons.whatshot,
          )),
          Tab(
              icon: Icon(
            Icons.notifications,
          )),
          Tab(
            icon: Icon(
              Icons.photo_camera,
              size: 35,
            ),
          ),
          Tab(
              icon: Icon(
            Icons.search,
          )),
          Tab(
              icon: Icon(
            Icons.account_circle,
          )),
        ],
      ),
    );
  }

  Scaffold unauth_screen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor
            ])),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "FlutterShare",
              style: TextStyle(
                  fontFamily: "Signatra", fontSize: 90, color: Colors.white),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            "assets/images/google_signin_button.png"),
                        fit: BoxFit.cover)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return is_Auth ? auth_screen() : unauth_screen();
  }
}
