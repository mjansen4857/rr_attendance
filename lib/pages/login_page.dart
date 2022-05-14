import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum SigninMethod {
  Google,
  Apple,
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  int? _teamNumber;
  String? _permissionCode;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(),
                    SizedBox(height: 48),
                    _buildTeamDropdown(),
                    SizedBox(height: 12),
                    _buildPermissionInput(),
                    SizedBox(height: 48),
                    _buildGoogleSignIn(),
                    _buildAppleSignIn(),
                    SizedBox(height: 12),
                    _buildErrorMessage(),
                  ],
                ),
              ),
            ),
          ),
          _buildLoading(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Image.asset('images/rr_logo.png'),
    );
  }

  Widget _buildTeamDropdown() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField<int>(
        dropdownColor: colorScheme.surfaceVariant,
        style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
        borderRadius: BorderRadius.circular(8),
        isExpanded: true,
        value: _teamNumber,
        icon: Icon(Icons.arrow_drop_down),
        validator: (value) => value == null ? 'Team number is required' : null,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(8),
          label: Text('Team Number'),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        items: [
          DropdownMenuItem<int>(
            value: 3015,
            child: Text('3015'),
          ),
          DropdownMenuItem<int>(
            value: 2716,
            child: Text('2716'),
          ),
        ],
        onChanged: (int? value) {
          setState(() {
            _teamNumber = value;
          });
        },
      ),
    );
  }

  Widget _buildPermissionInput() {
    return TextFormField(
      autocorrect: false,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(8),
        label: Text('Permission Code'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (String? value) {
        if (value != null && value.isEmpty) {
          return 'Permission code is required';
        }
        return null;
      },
      onSaved: (String? value) {
        setState(() {
          _permissionCode = value;
        });
      },
    );
  }

  Widget _buildGoogleSignIn() {
    return SignInButton(
      Buttons.GoogleDark,
      onPressed: () => _validateAndSubmit(SigninMethod.Apple),
    );
  }

  Widget _buildAppleSignIn() {
    return Visibility(
      visible: Platform.isIOS,
      child: SignInButton(
        Buttons.AppleDark,
        onPressed: () => _validateAndSubmit(SigninMethod.Google),
      ),
    );
  }

  Widget _buildErrorMessage() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 24,
      child: Visibility(
        visible: _errorMessage.isNotEmpty,
        child: Text(
          _errorMessage,
          style: TextStyle(fontSize: 16, color: colorScheme.error),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Visibility(
      visible: _isLoading,
      child: Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit(SigninMethod signinMethod) async {
    if (_validateAndSave()) {
      setState(() {
        _errorMessage = '';
        _isLoading = true;
      });
    }
  }
}
