import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/color_palette.dart';
import 'package:rr_attendance/custom_icons.dart';
import 'package:rr_attendance/pages/leaderboard_page.dart';
import 'package:rr_attendance/pages/settings_page.dart';
import 'package:rr_attendance/pages/time_card_page.dart';
import 'package:rr_attendance/pages/time_tracker_page.dart';
import 'package:rr_attendance/services/authentication.dart';

enum PageState { TIME_TRACKER, TIME_CARD }

class HomePage extends StatefulWidget {
  final FirebaseUser user;
  final Authentication auth;
  final VoidCallback logoutCallback;

  HomePage({this.user, this.auth, this.logoutCallback});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageState _pageState;

  void signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageState = PageState.TIME_TRACKER;
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
      body: buildPageContent(),
    );
  }

  Widget buildPageContent() {
    switch (_pageState) {
      case PageState.TIME_TRACKER:
        return TimeTracker();
      case PageState.TIME_CARD:
        return TimeCard();
      default:
        return TimeTracker();
    }
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
                  title: Text('Time tracker'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _pageState = PageState.TIME_TRACKER;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.list,
                    color: Colors.grey,
                  ),
                  title: Text('My time card'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _pageState = PageState.TIME_CARD;
                    });
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LeaderboardPage()));
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsPage()));
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
