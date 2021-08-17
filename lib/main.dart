import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttershare/models/provider_post_list.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

void main() {
  // Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_) {
  //   print("timestamp enabled successfully");
  // }, onError: (_) {
  //   print("Error in enabling timestamp");
  // });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ProviderPostList(),
      child: MaterialApp(
        title: 'FlutterShare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          accentColor: Colors.teal,
        ),
        home: Home(),
      ),
    );
  }
}
