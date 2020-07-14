import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/color_palette.dart';
import 'package:rr_attendance/services/authentication.dart';

class HomePage extends StatefulWidget {
  final FirebaseUser user;
  final Authentication auth;
  final VoidCallback logoutCallback;

  HomePage({this.user, this.auth, this.logoutCallback});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBG,
      body: Container(
        child: Center(
          child: SizedBox(
            height: 40.0,
            width: 150.0,
            child: RaisedButton(
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.indigo,
              child: Text(
                'Sign out',
                style: TextStyle(fontSize: 20.0, color: Colors.grey[200]),
              ),
              onPressed: signOut,
            ),
          ),
        ),
      ),
    );
  }
}
