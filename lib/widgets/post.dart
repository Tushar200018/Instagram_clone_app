import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/provider_post_list.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/comments.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/custom_image.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:flutter/animation.dart';
import 'package:provider/provider.dart';

class Post extends StatefulWidget {
  String postId;
  String ownerId;
  String mediaUrl;
  String location;
  String username;
  String description;
  dynamic likes;

  Post(
      {this.username,
      this.postId,
      this.mediaUrl,
      this.location,
      this.likes,
      this.ownerId,
      this.description});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      ownerId: doc["ownerId"],
      postId: doc["postId"],
      location: doc["location"],
      mediaUrl: doc["mediaUrl"],
      likes: doc["likes"],
      username: doc["username"],
      description: doc["description"],
    );
  }

  int getLikeCount() {
    int count = 0;
    if (likes == null) {
      return 0;
    } else {
      likes.values.forEach((val) {
        if (val) {
          count++;
        }
      });
    }
    return count;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      username: this.username,
      location: this.location,
      mediaUrl: this.mediaUrl,
      likes: this.likes,
      likesCount: getLikeCount(),
      description: this.description);
}

class _PostState extends State<Post> with TickerProviderStateMixin {
  String postId;
  String ownerId;
  String mediaUrl;
  String location;
  String username;
  dynamic likes;
  int likesCount;
  String description;

  _PostState(
      {this.username,
      this.postId,
      this.mediaUrl,
      this.location,
      this.likes,
      this.ownerId,
      this.likesCount,
      this.description});

  User owner;
  bool isLiked;
  bool showHeart = false;
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    isLiked = likes[currentUser.id] == true;

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //  controller.dispose();
    super.dispose();
  }

  @override
  buildPostHeader() {
    return FutureBuilder(
        future: usersRef.document(ownerId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress(context);
          }
          owner = User.fromDocument(snapshot.data);
          return ListTile(
            leading: GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Profile(
                            profileId: ownerId,
                          ))),
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(owner.photoUrl),
              ),
            ),
            title: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Profile(
                              profileId: ownerId,
                            )));
              },
              child: Text(
                username,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(location),
            trailing: currentUser.id == ownerId
                ? IconButton(
                    onPressed: () {
                      handlePostDelete();
                    },
                    icon: Icon(Icons.more_vert),
                  )
                : Text(""),
          );
        });
  }

  handlePostDelete() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Remove this post?"),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
                },
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              )
            ],
          );
        });
  }

  deletePost() async {
    // postsRef
    //     .document(ownerId)
    //     .collection("user posts")
    //     .document(postId)
    //     .get()
    //     .then((doc) {
    //   if (doc.exists) {
    //     doc.reference.delete();
    //   }
    // });

    Provider.of<ProviderPostList>(context, listen: false).deletePost(postId);

    activityFeedRef
        .document(ownerId)
        .collection("feedItems")
        .where("postId", isEqualTo: postId)
        .getDocuments()
        .then((snap) => {
              // ignore: sdk_version_set_literal
              snap.documents.forEach((doc) {
                if (doc.exists) {
                  doc.reference.delete();
                }
              })
            });

    storageRef.child("post_$postId.jpg").delete();

    QuerySnapshot commentSnapshot = await commentsRef
        .document(postId)
        .collection("comments")
        .where("postId", isEqualTo: postId)
        .getDocuments();
    commentSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () {
        handlePostLike();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          cachedNetworkImage(mediaUrl),
          showHeart
              ? ScaleTransition(
                  scale: animation,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red.withOpacity(0.7),
                    size: 70,
                  ),
                )
              : Text("")
        ],
      ),
    );
  }

  addLikeToActivityFeed() {
    if (currentUser.id != ownerId) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userProfilePhoto": currentUser.photoUrl,
        "userId": ownerId,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp
      });
    }
  }

  removeLikeFromActivityFeed() {
    if (currentUser.id != ownerId) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  handlePostLike() async {
    if (isLiked) {
      await postsRef
          .document(ownerId)
          .collection("user posts")
          .document(postId)
          .updateData({
        "likes": {currentUser.id: false}
      });
      removeLikeFromActivityFeed();
      setState(() {
        isLiked = false;
        likesCount -= 1;
      });
    } else {
      await postsRef
          .document(ownerId)
          .collection("user posts")
          .document(postId)
          .updateData({
        "likes": {currentUser.id: true}
      });
      addLikeToActivityFeed();
      setState(() {
        isLiked = true;
        likesCount += 1;
        showHeart = true;
        controller = AnimationController(
            vsync: this,
            duration: Duration(milliseconds: 400),
            lowerBound: 0.5,
            upperBound: 1);
        animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
        controller.forward();
        controller.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            controller.reverse();
          }
        });
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  buildPostFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.0),
              child: IconButton(
                onPressed: () {
                  handlePostLike();
                },
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.pink,
                  size: 28,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Comments(
                          postId: postId,
                          postOwnerId: ownerId,
                          postMediaUrl: mediaUrl),
                    ),
                  );
                },
                icon: Icon(
                  Icons.chat,
                  color: Colors.blue[900],
                  size: 28,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 25.0),
              child: Text(
                "$likesCount likes",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 25.0),
              child: Text(
                username,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: Text(description),
            )
          ],
        )
      ],
    );
  }

  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
        Divider()
      ],
    );
  }
}
