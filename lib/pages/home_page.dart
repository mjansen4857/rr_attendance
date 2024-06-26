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
import 'package:rr_attendance/widgets/user_update_dialog.dart';

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
  late List<NavigationDestination> _destinations;

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

        var userInfo = await Database.getUserInfo(user!);

        setState(() {
          _user = user;
          _isAdmin = userInfo.isAdmin;

          _destinations = [
            NavigationDestination(
              icon: Icon(Icons.timer),
              label: 'Time Tracker',
              tooltip: '',
            ),
            if (_dbSettings.leaderboardEnabled || _isAdmin)
              NavigationDestination(
                icon: Icon(Icons.leaderboard),
                label: 'Leaderboard',
                tooltip: '',
              ),
            if (_dbSettings.statsEnabled || _isAdmin)
              NavigationDestination(
                icon: Icon(Icons.insights),
                label: 'Stats',
                tooltip: '',
              ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
              tooltip: '',
            ),
            if (_isAdmin)
              NavigationDestination(
                icon: Icon(Icons.build),
                label: 'Control Panel',
                tooltip: '',
              ),
          ];
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

    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _buildBody(),
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(_destinations[_selectedTab].label),
        elevation: 1,
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildBody() {
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      onPageChanged: (int index) {
        setState(() {
          _selectedTab = index;
        });
      },
      children: [
        TimeTrackerPage(
          user: _user!,
        ),
        if (_dbSettings.leaderboardEnabled || _isAdmin)
          LeaderboardPage(
            user: _user!,
          ),
        if (_dbSettings.statsEnabled || _isAdmin) StatsPage(),
        SettingsPage(
          user: _user!,
          onSignOut: _signOut,
        ),
        if (_isAdmin)
          ControlPanelPage(
            resetPassword: _dbSettings.resetPassword,
          ),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return NavigationBar(
      selectedIndex: _selectedTab,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedTab = index;
          _pageController.jumpToPage(_selectedTab);
          // _pageController.animateToPage(
          //   _selectedTab,
          //   duration: Duration(milliseconds: 200),
          //   curve: Curves.easeInOut,
          // );
        });
      },
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      destinations: _destinations,
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

    User? user = await Authentication.getCurrentUser();

    if (newUser) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return UserUpdateDialog(
              user: user!,
            );
          });
    }

    return user;
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
