import 'package:flutter/material.dart';

class LoginSignupPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = GlobalKey<FormState>();

  String _email;
  String _password;
  String _errorMessage;

  bool _isLoading;
  bool _isLoginForm;

  void validateAndSubmit() async {}

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = '';
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
    //Color(0xff252730)
    return Scaffold(
      backgroundColor: Color(0xff252730),
      body: Stack(
        children: <Widget>[
          showForm(),
          showLoading(),
        ],
      ),
    );
  }

  Widget showForm() {
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
      padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
      child: Center(
        child: Container(
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
      padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
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
          fillColor: Color(0xff36393f),
        ),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
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
          fillColor: Color(0xff36393f),
        ),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
        style: TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }

  Widget showPrimaryButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: RaisedButton(
          elevation: 2.0,
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
      return Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }
}
