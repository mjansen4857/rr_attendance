import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/authentication.dart';
import 'package:rr_attendance/services/database.dart';

class LoginPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final VoidCallback loginCallback;
  final VoidCallback newUserCallback;

  LoginPage({this.auth, this.db, this.loginCallback, this.newUserCallback});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  int _teamNumber;
  String _permissionCode;
  String _errorMessage;

  bool _isLoading;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit(bool isGoogle) async {
    if (validateAndSave()) {
      setState(() {
        _errorMessage = '';
        _isLoading = true;
      });

      try {
        bool permission = await widget.db.validatePermission(_permissionCode);
        if (!permission) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Invalid permission code';
          });
        } else {
          User user;
          if (isGoogle) {
            user = await widget.auth.signInWithGoogle();
          } else {
            user = await widget.auth.signInWithApple();
          }
          bool newUser = await widget.db.addUserIfNotExists(user, _teamNumber);
          print('Signed in user: ${user.uid}');
          setState(() {
            _isLoading = false;
          });
          if (newUser) {
            widget.newUserCallback();
          } else {
            widget.loginCallback();
          }
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          _formKey.currentState.reset();
        });
      }
    }
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = '';
    _teamNumber = null;
  }

  @override
  void initState() {
    _errorMessage = '';
    _isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: CustomColors.background,
      body: Stack(
        children: <Widget>[
          buildForm(),
          buildLoading(),
        ],
      ),
    );
  }

  Widget buildForm() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            buildLogo(),
            buildTeamInput(),
            buildPermissionInput(),
            buildGoogleSignInButton(),
            buildAppleSignInButton(),
            buildErrorMessage(),
          ],
        ),
      ),
    );
  }

  Widget buildLoading() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget buildLogo() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
      child: Center(
        child: SizedBox(
          width: 150,
          height: 150,
          child: Image(image: AssetImage('images/rr_logo.png')),
        ),
      ),
    );
  }

  Widget buildTeamInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.grey[800],
        ),
        child: DropdownButtonFormField<int>(
          value: _teamNumber,
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 24,
          validator: (value) =>
              value == null ? 'Team number is required' : null,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10.0),
            hintText: 'Team Number',
            hintStyle: TextStyle(
              fontSize: 18.0,
              color: Colors.grey[400],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            // fillColor: darkAccent,
          ),
          elevation: 5,
          isExpanded: true,
          style: TextStyle(color: Colors.white, fontSize: 18.0),
          items: <DropdownMenuItem<int>>[
            DropdownMenuItem(
              value: 3015,
              child: Text(
                '3015',
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ),
            DropdownMenuItem(
              value: 2716,
              child: Text(
                '2716',
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ),
          ],
          onChanged: (int newValue) {
            setState(() {
              _teamNumber = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget buildPermissionInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        autofocus: false,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10.0),
          hintText: 'Permission Code',
          hintStyle: TextStyle(
            fontSize: 18.0,
            color: Colors.grey[400],
            backgroundColor: Colors.transparent,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          filled: true,
          // fillColor: darkAccent,
        ),
        validator: (value) =>
            value.isEmpty ? 'Permission code is required' : null,
        onSaved: (value) => _permissionCode = value.trim(),
        style: TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }

  Widget buildGoogleSignInButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 45, 0, 0),
      child: OutlineButton(
        onPressed: () {
          validateAndSubmit(true);
        },
        borderSide: BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage('images/google_logo.png'),
                height: 35,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(
                  'Sign in with Google',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAppleSignInButton() {
    var platform = Theme.of(context).platform;

    return Visibility(
      visible: platform == TargetPlatform.iOS,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: OutlineButton(
          onPressed: () {
            validateAndSubmit(false);
          },
          borderSide: BorderSide(color: Colors.grey),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage('images/apple_logo.png'),
                  height: 35,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(
                    'Sign in with Apple',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0.0, 0, 0),
        child: Text(
          _errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14.0,
              color: Colors.red,
              height: 1.0,
              fontWeight: FontWeight.w300),
        ),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }
}
