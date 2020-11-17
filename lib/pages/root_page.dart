import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/pages/home_page.dart';
import 'package:rr_attendance/pages/login_page.dart';
import 'package:rr_attendance/pages/onboarding_page.dart';
import 'package:rr_attendance/services/authentication.dart';
import 'package:rr_attendance/services/database.dart';

enum AuthStatus { NOT_DETERMINED, NOT_LOGGED_IN, LOGGED_IN, NEW_USER }

class RootPage extends StatefulWidget {
  final Authentication auth;
  final Database db;

  RootPage({this.auth, this.db});

  @override
  State<StatefulWidget> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  User _user;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _user = user;
        authStatus =
            user == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _user = user;
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void newUserCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _user = user;
      });
    });
    setState(() {
      authStatus = AuthStatus.NEW_USER;
    });
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _user = null;
    });
  }

  void onboardingDoneCallback() {
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildLoadingScreen();
      case AuthStatus.NOT_LOGGED_IN:
        return LoginPage(
          auth: widget.auth,
          db: widget.db,
          loginCallback: loginCallback,
          newUserCallback: newUserCallback,
        );
      case AuthStatus.NEW_USER:
        if (_user != null)
          return OnboardingPage(
            onboardingDoneCallback: onboardingDoneCallback,
          );
        return buildLoadingScreen();
      case AuthStatus.LOGGED_IN:
        if (_user != null)
          return HomePage(
              user: _user,
              auth: widget.auth,
              db: widget.db,
              logoutCallback: logoutCallback);
        return buildLoadingScreen();
      default:
        return buildLoadingScreen();
    }
  }

  Widget buildLoadingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
