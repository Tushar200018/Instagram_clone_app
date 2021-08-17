import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/post_screen.dart';
import 'package:fluttershare/pages/profile.dart';
import 'home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  void initState() {
    // getDocuments();
  }

  // getDocuments() async {
  //   QuerySnapshot snap = await activityFeedRef
  //       .document(currentUser.id)
  //       .collection("feedItems")
  //       .orderBy("timestamp", descending: true)
  //       .limit(50)
  //       .getDocuments();
  //   snap.documents.forEach((doc) {
  //     print(doc.data);
  //   });
  // }

  @override
  List<ActivityFeedItem> notifications = [];

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, Title: "Activity Feed"),
      body: Container(
        child: FutureBuilder<QuerySnapshot>(
          future: activityFeedRef
              .document(currentUser.id)
              .collection("feedItems")
              .orderBy("timestamp", descending: true)
              .limit(50)
              .getDocuments(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress(context);
            }

            notifications = snapshot.data.documents.map((doc) {
              return ActivityFeedItem.fromDocument(doc);
            }).toList();

            return ListView(
              children: notifications,
            );
          },
        ),
      ),
    );
  }
}

class ActivityFeedItem extends StatelessWidget {
  String username;
  String postId;
  String type;
  String commentData;
  String userId;
  String mediaUrl;
  String userProfilePhoto;
  Timestamp timestamp;

  ActivityFeedItem(
      {this.timestamp,
      this.mediaUrl,
      this.username,
      this.postId,
      this.userId,
      this.commentData,
      this.type,
      this.userProfilePhoto});

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc["username"],
      mediaUrl: doc["mediaUrl"],
      userId: doc["userId"],
      userProfilePhoto: doc["userProfilePhoto"],
      commentData: doc["commentData"],
      type: doc["type"],
      timestamp: doc["timestamp"],
      postId: doc["postId"],
    );
  }

  @override
  Widget mediaPreview;
  String activityItemText;

  configureMediaPreview(BuildContext context) {
    if (type == "like" || type == "comment") {
      mediaPreview = GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PostScreen(postId: postId, userId: userId);
          }));
        },
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(mediaUrl),
                      fit: BoxFit.cover)),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }

    if (type == "like") {
      activityItemText = " liked your post";
    } else if (type == "follow") {
      activityItemText = " is following you";
    } else if (type == "comment") {
      activityItemText = " replied: $commentData";
    } else {
      activityItemText = " Error unknown type: '$type'";
    }
  }

  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Profile(
                            profileId: userId,
                          )));
            },
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(
                        text: username,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: activityItemText)
                  ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfilePhoto),
            backgroundColor: Colors.grey,
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}
