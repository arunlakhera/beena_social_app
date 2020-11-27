import 'package:beena_social_app/pages/MemoryPage.dart';
import 'package:beena_social_app/widgets/MemoryWidget.dart';
import 'package:flutter/material.dart';

class MemoryTile extends StatelessWidget {
  final Memory memory;

  MemoryTile({this.memory});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => displayFullPost(context),
      child: Image.network(memory.urlImage1),
    );
  }

  displayFullPost(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) =>
    //         MemoryPage(postId: post.postId, userId: post.ownerId),
    //   ),
    // );
  }
}
