import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/pages/HomePage.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //Firestore.instance.settings();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beena',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: colorBlack,
        dialogBackgroundColor: colorBlack,
        accentColor: colorBlack,
        primarySwatch: colorGrey,
        cardColor: colorWhite,
      ),
      home: HomePage(),
    );
  }
}
