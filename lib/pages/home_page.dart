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
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_user == null) {
      return Container();
    }

    return Center(
      child: Text('Signed in'),
    );
  }
}
