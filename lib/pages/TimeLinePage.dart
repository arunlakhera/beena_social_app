import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/widgets/HeaderWidget.dart';
import 'package:beena_social_app/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';

class TimeLinePage extends StatefulWidget {
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        isAppTitle: true,
      ),
      body: SafeArea(
        child: circularProgress(),
      ),
    );
  }
}
