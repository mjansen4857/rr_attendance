import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/color_palette.dart';
import 'package:rr_attendance/custom_icons.dart';
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
      appBar: AppBar(
        title: Text('Attendance'),
        backgroundColor: Colors.indigo,
      ),
      drawer: buildDrawer(),
      body: Container(),
    );
  }

  Widget buildDrawer() {
    return Drawer(
      elevation: 5,
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountEmail: Text(widget.user.email),
                  accountName: Text(widget.user.displayName),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage('images/rr_logo.jpg'),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.timer,
                    color: Colors.grey,
                  ),
                  title: Text('Track time'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    CustomIcons.leaderboard,
                    color: Colors.grey,
                    size: 16,
                  ),
                  title: Text('Leaderboard'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
          Container(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Container(
                child: Column(
                  children: <Widget>[
                    Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.settings,
                        color: Colors.grey,
                      ),
                      title: Text(
                        'Settings',
                        style: TextStyle(fontSize: 15),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.exit_to_app,
                        color: Colors.grey,
                      ),
                      title: Text(
                        'Sign out',
                        style: TextStyle(fontSize: 15),
                      ),
                      onTap: signOut,
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
