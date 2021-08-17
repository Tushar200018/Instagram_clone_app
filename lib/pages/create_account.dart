import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  @override
  String username;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  submit() {
    final form = formKey.currentState;
    if (form.validate()) {
      SnackBar snackBar = SnackBar(
        content: Text("Welcome $username!"),
      );
      scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 3), () {
        Navigator.pop(context, username);
      });
    }
  }

  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: scaffoldKey,
      appBar: header(context, Title: "Set up your profile"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                "Create a Username",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 25, bottom: 15, left: 10, right: 10),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                validator: (val) {
                  if (val.trim().length < 5) {
                    return "username too short";
                  } else if (val.trim().length > 15) {
                    return "username too long";
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  username = value;
                },
                decoration: InputDecoration(
                  labelText: "Username",
                  labelStyle: TextStyle(fontSize: 15),
                  hintText: "Must be atleast 5 characters",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                  ),
                  // errorBorder: OutlineInputBorder(
                  //   borderSide: BorderSide(color: Colors.red, width: 2),
                  // ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: submit,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(7)),
              child: Text(
                "Submit",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              alignment: Alignment.center,
            ),
          )
        ],
      ),
    );
  }
}
