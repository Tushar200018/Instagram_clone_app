import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'home.dart';
import 'package:fluttershare/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  String userId;
  String postId;

  PostScreen({this.postId, this.userId});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: postsRef
            .document(userId)
            .collection("user posts")
            .document(postId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress(context);
          }
          Post post = Post.fromDocument(snapshot.data);
          return Scaffold(
            appBar: header(context, Title: post.description),
            body: Container(
              child: post,
            ),
          );
        });
  }
}
