import 'package:beena_social_app/widgets/HeaderWidget.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: 'Notification'),
      body: SafeArea(
        child: Text(
          'Activity Feed Page goes here',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class NotificationsItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Activity Feed Item goes here',
      style: TextStyle(color: Colors.white),
    );
  }
}
