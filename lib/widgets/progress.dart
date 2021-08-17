import 'package:flutter/material.dart';

Container circularProgress(context) {
  return Container(
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      color: Theme.of(context).primaryColor,
    ),
  );
}

Container linearProgress(context) {
  return Container(
    padding: EdgeInsets.only(bottom: 10),
    child: LinearProgressIndicator(
      color: Theme.of(context).primaryColor,
    ),
  );
}
