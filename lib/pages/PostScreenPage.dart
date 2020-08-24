import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:beena_social_app/widgets/HeaderWidget.dart';
import 'package:beena_social_app/widgets/PostWidget.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';

class PostScreenPage extends StatelessWidget {
  final String postId;
  final String userId;

  PostScreenPage({this.postId, this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsReference
          .document(userId)
          .collection('usersPosts')
          .document(postId)
          .get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(dataSnapshot.data);
        return Center(
          child: Scaffold(
            backgroundColor: colorWhite,
            appBar: header(context, strTitle: post.description),
            body: ListView(
              children: [
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
