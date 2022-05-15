import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/pages/login_page.dart';
import 'package:rr_attendance/services/authentication.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;

  @override
  void initState() {
    Authentication.getCurrentUser().then((user) async {
      if (user == null) {
        bool newUser = await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, anim1, anim2) => LoginPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ));

        user = await Authentication.getCurrentUser();
      }

      setState(() {
        _user = user;
      });
    });
    super.initState();
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
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildBody() {
    return Center(
      child: Text('Signed in'),
    );
  }

  Widget _buildDrawer() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_user!.displayName ?? ''),
              accountEmail: Text(_user!.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: colorScheme.surfaceVariant,
                foregroundImage: (_user!.photoURL != null)
                    ? NetworkImage(_user!.photoURL!)
                    : Image.asset('images/profile.png').image,
              ),
            ),
            ListTile(
              leading: Icon(Icons.timer),
              title: Text('Time Tracker'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.leaderboard),
              title: Text('Leaderboard'),
              onTap: () {},
            ),
            Expanded(
              child: Container(),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.add_alert),
              title: Text('Requests'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.build),
              title: Text('Control Panel'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
              onTap: () {},
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
