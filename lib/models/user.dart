import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String username;
  String photoUrl;
  String email;
  String displayName;
  String bio;

  User(
      {this.displayName,
      this.photoUrl,
      this.username,
      this.email,
      this.bio,
      this.id});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc["id"],
        username: doc["username"],
        photoUrl: doc["photoUrl"],
        email: doc["email"],
        displayName: doc["displayName"],
        bio: doc["bio"]);
  }
}
