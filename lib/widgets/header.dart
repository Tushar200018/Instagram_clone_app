import 'package:flutter/material.dart';

AppBar header(context,
    {String Title, bool isAppTitle = false, bool backbutton = false}) {
  return AppBar(
    automaticallyImplyLeading: backbutton,
    title: Text(
      Title,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontFamily: isAppTitle ? "Signatra" : "",
          fontSize: isAppTitle ? 50 : 22,
          color: Colors.white),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
