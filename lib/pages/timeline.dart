import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  final firestore_instance = Firestore.instance;
  List<Post> posts;
  List<String> followingList = [];

  @override
  void initState() {
    // TODO: implement initState
    getFollowingList();
    getTimeline();
    super.initState();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(currentUser.id)
        .collection("timelinePosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  getFollowingList() async {
    QuerySnapshot snapshot = await followingRef
        .document(currentUser.id)
        .collection("usersFollowing")
        .getDocuments();
    setState(() {
      followingList = snapshot.documents.map((doc) => doc.documentID).toList();
    });
  }

  buildUsersToFollow() {
    return StreamBuilder<QuerySnapshot>(
        stream: usersRef
            .orderBy("timestamp", descending: true)
            .limit(30)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress(context);
          }
          List<UserResult> followerRecommendations = [];
          snapshot.data.documents.forEach((doc) {
            User user = User.fromDocument(doc);
            bool isCurrentUser = currentUser.id == user.id;
            bool isFollowingUser = followingList.contains(user.id);

            if (!isCurrentUser && !isFollowingUser) {
              return followerRecommendations.add(UserResult(user: user));
            }
          });
          return Container(
            color: Theme.of(context).accentColor.withOpacity(0.2),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add,
                        color: Theme.of(context).primaryColor,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Users To Follow",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 30),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: ListView(
                    shrinkWrap: true,
                    children: followerRecommendations,
                  ),
                )
              ],
            ),
          );
        });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress(context);
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView(
        children: posts,
      );
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true, Title: "FlutterShare"),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
