import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'home.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  String postId;
  String postOwnerId;
  String postMediaUrl;

  Comments({this.postId, this.postMediaUrl, this.postOwnerId});

  @override
  CommentsState createState() => CommentsState(
      postId: this.postId,
      postMediaUrl: this.postMediaUrl,
      postOwnerId: this.postOwnerId);
}

class CommentsState extends State<Comments> {
  String postId;
  String postOwnerId;
  String postMediaUrl;

  CommentsState({this.postId, this.postMediaUrl, this.postOwnerId});

  buildComments() {
    return StreamBuilder<QuerySnapshot>(
        stream: commentsRef
            .document(postId)
            .collection("comments")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress(context);
          }

          comment_list = snapshot.data.documents
              .map((doc) => Comment.fromDocument(doc))
              .toList();

          return ListView(
            children: comment_list,
          );
        });
  }

  addComment() {
    commentsRef.document(postId).collection("comments").add({
      "username": currentUser.username,
      "comment": controller.text,
      "photoUrl": currentUser.photoUrl,
      "timestamp": timestamp,
      "userId": currentUser.id,
      "postId": postId
    });
    if (currentUser.id != postOwnerId) {
      activityFeedRef.document(postOwnerId).collection("feedItems").add({
        "type": "comment",
        "commentData": controller.text,
        "username": currentUser.username,
        "userProfilePhoto": currentUser.photoUrl,
        "userId": postOwnerId,
        "postId": postId,
        "mediaUrl": postMediaUrl,
        "timestamp": timestamp
      });
    }

    controller.clear();
  }

  @override
  TextEditingController controller = TextEditingController();
  List<Comment> comment_list = [];

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, Title: "Comments"),
        body: Column(
          children: [
            Expanded(
              child: buildComments(),
            ),
            Divider(),
            ListTile(
              title: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: "Write a comment ...",
                ),
              ),
              trailing: OutlinedButton(
                onPressed: () {
                  addComment();
                },
                child: Text("Post"),
                style: ButtonStyle(
                    side: MaterialStateProperty.all(BorderSide.none)),
              ),
            )
          ],
        ));
  }
}

class Comment extends StatelessWidget {
  String username;
  String commnent;
  String userId;
  String photoUrl;
  Timestamp timestamp;

  Comment(
      {this.timestamp,
      this.photoUrl,
      this.username,
      this.commnent,
      this.userId});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc["username"],
      commnent: doc["comment"],
      userId: doc["userId"],
      photoUrl: doc["photoUrl"],
      timestamp: doc["timestamp"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: Text(
            commnent,
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider()
      ],
    );
  }
}
