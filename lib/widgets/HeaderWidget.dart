import 'package:beena_social_app/constants.dart';
import 'package:flutter/material.dart';

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
        fontFamily: isAppTitle ? 'Signatra' : '',
        fontSize: isAppTitle ? 45.0 : 22.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: colorWhite, //Theme.of(context).accentColor,
  );
}
