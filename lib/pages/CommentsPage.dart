import 'package:flutter/material.dart';

class CommentsPage extends StatefulWidget {
  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Here goes Comments Page',
      style: TextStyle(color: Colors.white),
    );
  }
}

class Comment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Comment',
      style: TextStyle(color: Colors.white),
    );
  }
}
