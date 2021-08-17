// import 'dart:html';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/provider_post_list.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/widgets/post_tile.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'edit_profile.dart';
import 'package:fluttershare/widgets/post.dart';

class Profile extends StatefulWidget {
  String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isGridView = true;

  int followersCount;
  int followingCount;

  @override
  void initState() {
    checkIfFollowing();
    getFollowers();
    getFollowing();
    getProfilePosts();
    super.initState();
  }

  checkIfFollowing() {
    setState(() {
      isLoading = true;
    });
    followingRef
        .document(currentUser.id)
        .collection("usersFollowing")
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          isFollowing = true;
        });
      } else {
        setState(() {
          isFollowing = false;
        });
      }
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection("userFollowers")
        .getDocuments();
    setState(() {
      followersCount = snapshot.documents.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection("usersFollowing")
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection("user posts")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    setState(() {
      posts = snapshot.documents.map((doc) {
        return Post.fromDocument(doc);
      }).toList();
      postCount = posts.length;
      isLoading = false;
    });
  }

  void logout() {
    googleSignIn.signOut();
    auth.signOut();
  }

  @override
  User profileUser;
  List<Post> posts = [];
  bool isLoading = false;
  int postCount;
  bool isFollowing = false;

  getProfileHeader() {
    if (isLoading) {
      return circularProgress(context);
    }
    return FutureBuilder(
        future: usersRef.document(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress(context);
          }
          profileUser = User.fromDocument(snapshot.data);
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(profileUser.photoUrl),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildColumnHeader("Posts", postCount),
                              buildColumnHeader(
                                  "Followers", followersCount - 1),
                              buildColumnHeader("Following", followingCount),
                            ],
                          ),
                          buildProfileButton()
                        ],
                      ),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text(
                        profileUser.username,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        profileUser.displayName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(profileUser.bio),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  Column buildColumnHeader(String label, int count) {
    return Column(
      children: [
        Text(
          "$count",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 2),
          child: Text(
            label,
            style: TextStyle(
                fontSize: 13,
                color: Colors.black,
                fontWeight: FontWeight.normal),
          ),
        )
      ],
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress(context);
    }
    if (isGridView == false) {
      return Column(
        children: posts,
      );
    }
    List<GridTile> gridTile = [];
    posts.forEach((post) {
      gridTile.add(GridTile(child: PostTile(post: post)));
    });
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 1.5,
      crossAxisSpacing: 1.5,
      childAspectRatio: 1,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: gridTile,
    );
  }

  buildProfileButton() {
    bool sameUser = currentUser.id == profileUser.id;
    if (sameUser) {
      return buildButton("Edit Profile", () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditProfile(
                      logout: logout,
                    )));
      });
    } else if (isFollowing) {
      return buildButton("Unfollow", handleUnfollowUser);
    } else if (!isFollowing) {
      return buildButton("Follow", handleFollowUser);
    }
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
      followersCount++;
    });
    followersRef
        .document(profileUser.id)
        .collection("userFollowers")
        .document(currentUser.id)
        .setData({});
    followingRef
        .document(currentUser.id)
        .collection("usersFollowing")
        .document(profileUser.id)
        .setData({});

    activityFeedRef
        .document(profileUser.id)
        .collection("feedItems")
        .document(currentUser.id)
        .setData({
      "type": "follow",
      "ownerId": profileUser.id,
      "username": currentUser.username,
      "userId": currentUser.id,
      "userProfilePhoto": currentUser.photoUrl,
      "timestamp": timestamp,
    });
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
      followersCount--;
    });
    followersRef
        .document(profileUser.id)
        .collection("userFollowers")
        .document(currentUser.id)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    followingRef
        .document(currentUser.id)
        .collection("usersFollowing")
        .document(profileUser.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    activityFeedRef
        .document(profileUser.id)
        .collection("feedItems")
        .document(currentUser.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  buildButton(String text, Function function) {
    return GestureDetector(
      onTap: function,
      child: Container(
        decoration: BoxDecoration(
          color: isFollowing ? Colors.white : Colors.blue,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.withOpacity(0.7)),
        ),
        margin: EdgeInsets.only(top: 10),
        alignment: Alignment.center,
        width: 250,
        height: 27,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  buildTogglePostLook() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              isGridView = true;
            });
          },
          icon: Icon(
            Icons.grid_on,
            color: isGridView ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              isGridView = false;
            });
          },
          icon: Icon(
            Icons.list,
            color: isGridView ? Colors.grey : Theme.of(context).primaryColor,
          ),
        )
      ],
    );
  }

  CurrentUserCheck() async {
    if (currentUser.id == widget.profileId) {
      setState(() {
        isLoading = true;
      });
      List<Post> post_list =
          await Provider.of<ProviderPostList>(context).getCurrentUserPostList();
      setState(() {
        posts = post_list;
        print(posts.length);
        postCount = posts.length;
        isLoading = false;
      });
    }
  }

  Widget build(BuildContext context) {
    // CurrentUserCheck();
    return Scaffold(
      appBar: header(context, Title: "Profile"),
      body: ListView(
        children: [
          getProfileHeader(),
          posts.isEmpty ? Text("") : Divider(),
          posts.isEmpty ? Text("") : buildTogglePostLook(),
          posts.isEmpty ? Text("") : Divider(),
          buildProfilePosts()
        ],
      ),
    );
  }
}
