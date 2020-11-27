import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/pages/SearchPage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

AppBar header(context,
    {bool isAppTitle = false, String strTitle, hideBackButton = false}) {
  return AppBar(
    iconTheme: IconThemeData(
      color: colorBlack,
    ),
    automaticallyImplyLeading: hideBackButton ? false : true,
    title: Text(
      isAppTitle ? 'Been-A-Snap!' : strTitle,
      style: TextStyle(
        color: colorBlack,
        fontFamily: isAppTitle ? 'Signatra' : 'Signatra',
        fontSize: isAppTitle ? 35.0 : 30.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: false,
    backgroundColor: colorWhite, //Theme.of(context).accentColor,
    actions: [
      IconButton(
        icon: FaIcon(
          FontAwesomeIcons.searchPlus,
          size: 25,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return SearchPage();
              },
            ),
          );
        },
      )
    ],
  );
}
