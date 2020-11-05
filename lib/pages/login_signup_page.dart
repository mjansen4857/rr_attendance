import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/authentication.dart';
import 'package:rr_attendance/services/database.dart';

class LoginSignupPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final VoidCallback loginCallback;

  LoginSignupPage({this.auth, this.db, this.loginCallback});

  @override
  State<StatefulWidget> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = GlobalKey<FormState>();

  String _email;
  String _password;
  String _name;
  int _teamNumber;
  String _errorMessage;

  bool _isLoading;
  bool _isLoginForm;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() {
        _errorMessage = '';
        _isLoading = true;
      });

      FirebaseUser user;
      try {
        if (_isLoginForm) {
          user = await widget.auth.signIn(_email, _password);
          print('Signed in: ${user.uid}');
        } else {
          user = await widget.auth.signUp(_email, _password, _name);
          user = await widget.auth.signIn(_email, _password);
          await widget.db.addUser(user, _teamNumber);
          print('Signed up user: ${user.uid}');
        }
        setState(() {
          _isLoading = false;
        });
        if (user != null) {
          widget.loginCallback();
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

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  @override
  void initState() {
    _errorMessage = '';
    _isLoading = false;
    _isLoginForm = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: CustomColors.background,
      body: Stack(
        children: <Widget>[
          showForm(),
          showLoading(),
        ],
      ),
    );
  }

  Widget showForm() {
    if (_isLoginForm) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              showLogo(),
              showEmailInput(),
              showPasswordInput(),
              showPrimaryButton(),
              showSecondaryButton(),
              showErrorMessage(),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            showLogo(),
            showEmailInput(),
            showPasswordInput(),
            showNameInput(),
            showTeamInput(),
            showPrimaryButton(),
            showSecondaryButton(),
            showErrorMessage(),
          ],
        ),
      ),
    );
  }

  Widget showLoading() {
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

  Widget showLogo() {
    double r = 60.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, _isLoginForm ? 70.0 : 25.0, 0.0, 0.0),
      child: Center(
        child: SizedBox(
          width: r * 2,
          height: r * 2,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: r,
            backgroundImage: AssetImage('images/rr_logo.jpg'),
          ),
        ),
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, _isLoginForm ? 70.0 : 50.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10.0),
          hintText: 'Email',
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
        validator: (value) => value.isEmpty ? 'Email is required' : null,
        onSaved: (value) => _email = value.trim(),
        style: TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10.0),
          hintText: 'Password',
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
        validator: (value) => value.length < 6
            ? 'Password should be at least 6 characters long'
            : null,
        onSaved: (value) => _password = value.trim(),
        style: TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }

  Widget showNameInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        autofocus: false,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10.0),
          hintText: 'Full Name',
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
        validator: (value) => value.isEmpty ? 'Name is required' : null,
        onSaved: (value) => _name = value.trim(),
        style: TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }

  Widget showTeamInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
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

  Widget showPrimaryButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: RaisedButton(
          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          color: Colors.indigo,
          child: Text(
            _isLoginForm ? 'Login' : 'Create account',
            style: TextStyle(fontSize: 20.0, color: Colors.grey[200]),
          ),
          onPressed: validateAndSubmit,
        ),
      ),
    );
  }

  Widget showSecondaryButton() {
    return FlatButton(
      child: Text(
        _isLoginForm ? 'Create an account' : 'Have an account? Sign in',
        style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w300,
            color: Colors.grey[400]),
      ),
      onPressed: toggleFormMode,
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
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
