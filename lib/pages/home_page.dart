import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/pages/control_panel_page.dart';
import 'package:rr_attendance/pages/leaderboard_page.dart';
import 'package:rr_attendance/pages/login_page.dart';
import 'package:rr_attendance/pages/stats_page.dart';
import 'package:rr_attendance/pages/settings_page.dart';
import 'package:rr_attendance/pages/time_tracker_page.dart';
import 'package:rr_attendance/services/authentication.dart';
import 'package:rr_attendance/services/database.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Settings _dbSettings;
  User? _user;
  bool _isAdmin = false;
  int _selectedTab = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    Database.getSettings().then((settings) {
      _dbSettings = settings;

      Authentication.getCurrentUser().then((user) async {
        if (user == null) {
          user = await _showSignin();
        }

        bool admin = await Database.isUserAdmin(user!);

        setState(() {
          _user = user;
          _isAdmin = admin;
        });
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Container();
    }

    return Scaffold(
      body: _buildBody(),
      appBar: AppBar(
        title: Text('Attendance'),
        elevation: 1,
        leading: IconButton(
          onPressed: _signOut,
          icon: Icon(Icons.logout),
          tooltip: 'Sign Out',
        ),
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildBody() {
    return PageView(
      controller: _pageController,
      children: [
        TimeTrackerPage(),
        if (_dbSettings.leaderboardEnabled) LeaderboardPage(),
        StatsPage(),
        SettingsPage(),
        if (_isAdmin) ControlPanelPage(),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return NavigationBar(
      selectedIndex: _selectedTab,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedTab = index;
          _pageController.animateToPage(
            _selectedTab,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        });
      },
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.timer),
          label: 'Time Tracker',
        ),
        if (_dbSettings.leaderboardEnabled)
          NavigationDestination(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
        NavigationDestination(
          icon: Icon(Icons.insights),
          label: 'Stats',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
        if (_isAdmin)
          NavigationDestination(
            icon: Icon(Icons.build),
            label: 'Control Panel',
          ),
      ],
    );
  }

  Future<User?> _showSignin() async {
    bool newUser = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => LoginPage(
            permissionCode: _dbSettings.permissionCode,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ));

    return await Authentication.getCurrentUser();
  }

  void _signOut() async {
    Authentication.signOut();
    setState(() {
      _user = null;
    });

    _showSignin().then((user) {
      setState(() {
        _user = user;
      });
    });
  }
}
