import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/pages/login_page.dart';
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
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    Database.getSettings().then((settings) {
      _dbSettings = settings;

      Authentication.getCurrentUser().then((user) async {
        if (user == null) {
          user = await _showSignin();
        }

        setState(() {
          _user = user;
        });
      });
    });
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
        leading: MediaQuery.of(context).size.width < 640
            ? IconButton(
                onPressed: _signOut,
                icon: Icon(Icons.logout),
                tooltip: 'Sign Out',
              )
            : null,
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 640
          ? _buildNavigationBar()
          : null,
    );
  }

  Widget _buildBody() {
    return Row(
      children: [
        if (MediaQuery.of(context).size.width >= 640) _buildNavigationRail(),
        Expanded(
          child: Center(
            child: Text('Signed in'),
          ),
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
        });
      },
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.timer),
          label: 'Time Tracker',
        ),
        NavigationDestination(
          icon: Icon(Icons.leaderboard),
          label: 'Leaderboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_alert),
          label: 'Requests',
        ),
        NavigationDestination(
          icon: Icon(Icons.build),
          label: 'Control Panel',
        ),
      ],
    );
  }

  Widget _buildNavigationRail() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return NavigationRail(
      selectedIndex: _selectedTab,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedTab = index;
        });
      },
      labelType: NavigationRailLabelType.selected,
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: IconButton(
              onPressed: _signOut,
              icon: Icon(Icons.logout),
              tooltip: 'Sign Out',
            ),
          ),
        ),
      ),
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.timer),
          label: Text('Time Tracker'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.leaderboard),
          label: Text('Leaderboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.add_alert),
          label: Text('Requests'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.build),
          label: Text('Control Panel'),
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
