import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/pages/home.dart';

class ProviderPostList extends ChangeNotifier {
  List<Post> currentUserPostList = [];

  Future<List<Post>> getCurrentUserPostList() async {
    QuerySnapshot snapshot = await postsRef
        .document(currentUser.id)
        .collection("user posts")
        .getDocuments();
    currentUserPostList =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    return currentUserPostList;
  }

  deletePost(String postId) {
    postsRef
        .document(currentUser.id)
        .collection("user posts")
        .document(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        Post post = Post.fromDocument(doc);
        currentUserPostList.remove(post);
        doc.reference.delete();
      }
    });
    notifyListeners();
  }
}
