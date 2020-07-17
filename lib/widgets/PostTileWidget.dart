import 'package:beena_social_app/pages/PostScreenPage.dart';
import 'package:beena_social_app/widgets/PostWidget.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile({this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => displayFullPost(context),
      child: Image.network(post.url),
    );
  }

  displayFullPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PostScreenPage(postId: post.postId, userId: post.ownerId),
      ),
    );
  }
}
