import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/custom_icons.dart';
import 'package:rr_attendance/pages/control_panel_page.dart';
import 'package:rr_attendance/pages/leaderboard_page.dart';
import 'package:rr_attendance/pages/requests_page.dart';
import 'package:rr_attendance/pages/settings_page.dart';
import 'package:rr_attendance/pages/time_card_page.dart';
import 'package:rr_attendance/pages/time_tracker_page.dart';
import 'package:rr_attendance/services/authentication.dart';
import 'package:rr_attendance/services/database.dart';
import 'package:rr_attendance/services/notifications.dart';

enum PageState {
  TIME_TRACKER,
  TIME_CARD,
  LEADERBOARD,
  REQUESTS,
  CONTROL_PANEL,
  SETTINGS
}

class HomePage extends StatefulWidget {
  final User user;
  final Authentication auth;
  final Database db;
  final VoidCallback logoutCallback;
  final Notifications notifications;

  HomePage(
      {this.user, this.auth, this.db, this.logoutCallback, this.notifications});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageState _pageState = PageState.TIME_TRACKER;
  bool _isAdmin = false;
  bool _leaderboardEnabled = false;

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
    widget.db.isUserAdmin(widget.user).then((isAdmin) {
      widget.db.isLeaderboardEnabled().then((leaderboardEnabled) {
        setState(() {
          _isAdmin = isAdmin;
          _leaderboardEnabled = leaderboardEnabled;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: buildAppBar(),
        drawer: buildDrawer(),
        body: buildPageContent(),
      ),
    );
  }

  Widget buildAppBar() {
    switch (_pageState) {
      case PageState.TIME_CARD:
        return AppBar(
          title: Text('Logged Hours'),
          backgroundColor: Colors.indigo,
        );
      case PageState.LEADERBOARD:
        return AppBar(
          title: Text('Leaderboard'),
          backgroundColor: Colors.indigo,
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(
                text: '3015',
              ),
              Tab(
                text: '2716',
              )
            ],
          ),
        );
      case PageState.REQUESTS:
        return AppBar(
          title: Text('Requests'),
          backgroundColor: Colors.indigo,
        );
      case PageState.CONTROL_PANEL:
        return AppBar(
          title: Text('Control Panel'),
          backgroundColor: Colors.indigo,
        );
      case PageState.SETTINGS:
        return AppBar(
          title: Text('Settings'),
          backgroundColor: Colors.indigo,
        );
      case PageState.TIME_TRACKER:
      default:
        return AppBar(
          title: Text('Time Tracker'),
          backgroundColor: Colors.indigo,
        );
    }
  }

  Widget buildPageContent() {
    switch (_pageState) {
      case PageState.TIME_CARD:
        return TimeCardPage(
          user: widget.user,
          db: widget.db,
        );
      case PageState.LEADERBOARD:
        return LeaderboardPage(
          user: widget.user,
          db: widget.db,
        );
      case PageState.REQUESTS:
        return RequestsPage(
          db: widget.db,
        );
      case PageState.CONTROL_PANEL:
        return ControlPanelPage(
          db: widget.db,
        );
      case PageState.SETTINGS:
        return SettingsPage(
          user: widget.user,
          db: widget.db,
        );
      case PageState.TIME_TRACKER:
      default:
        return TimeTracker(
          user: widget.user,
          db: widget.db,
          notifications: widget.notifications,
        );
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
                    backgroundColor: Colors.grey[850],
                    backgroundImage: (widget.user.photoURL != null)
                        ? NetworkImage(widget.user.photoURL)
                        : AssetImage('images/profile.png'),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.timer,
                    color: Colors.grey,
                  ),
                  title: Text('Time Tracker'),
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
                  title: Text('Logged Hours'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _pageState = PageState.TIME_CARD;
                    });
                  },
                ),
                Visibility(
                  child: ListTile(
                    leading: Icon(
                      CustomIcons.leaderboard,
                      color: Colors.grey,
                      size: 16,
                    ),
                    title: Text('Leaderboard'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        if (_leaderboardEnabled || _isAdmin) {
                          _pageState = PageState.LEADERBOARD;
                        }
                      });
                    },
                  ),
                  visible: _leaderboardEnabled || _isAdmin,
                ),
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
                    Visibility(
                      child: ListTile(
                        leading: Icon(
                          Icons.add_alert,
                          color: Colors.grey,
                        ),
                        title: Text('Requests'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _pageState = PageState.REQUESTS;
                          });
                        },
                      ),
                      visible: _isAdmin,
                    ),
                    Visibility(
                      child: ListTile(
                        leading: Icon(
                          Icons.build,
                          color: Colors.grey,
                        ),
                        title: Text('Control Panel'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _pageState = PageState.CONTROL_PANEL;
                          });
                        },
                      ),
                      visible: _isAdmin,
                    ),
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
                        setState(() {
                          _pageState = PageState.SETTINGS;
                        });
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
