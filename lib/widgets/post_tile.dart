import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/post_screen.dart';
import 'package:fluttershare/widgets/post.dart';
import 'custom_image.dart';

class PostTile extends StatelessWidget {
  Post post;
  PostTile({this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PostScreen(
                      userId: post.ownerId,
                      postId: post.postId,
                    )));
      },
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
