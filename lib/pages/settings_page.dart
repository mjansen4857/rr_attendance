import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';

class SettingsPage extends StatefulWidget {
  final User user;
  final VoidCallback onSignOut;

  SettingsPage({
    required this.user,
    required this.onSignOut,
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController? _nameController;
  int? _teamNumber;

  @override
  void initState() {
    super.initState();

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'settings');

    Database.getUserInfo(widget.user).then((userInfo) {
      setState(() {
        _nameController = _getController(userInfo.name);
        _teamNumber = userInfo.team;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onSignOut,
        label: Text('Sign Out'),
        icon: Icon(Icons.logout),
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: TextField(
                            onSubmitted: (val) {
                              if (val.length > 0) {
                                FocusScopeNode currentScope =
                                    FocusScope.of(context);
                                if (!currentScope.hasPrimaryFocus &&
                                    currentScope.hasFocus) {
                                  FocusManager.instance.primaryFocus!.unfocus();
                                }

                                Database.updateUserName(widget.user, val);
                              }
                            },
                            controller: _nameController,
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                              labelText: 'Full Name',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTeamDropdown(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: Platform.isIOS,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: colorScheme.surface,
                            title: Text('Request Account Deletion'),
                            content: Text(
                                'Are you sure you want to request account deletion? This is a manual process and will take up to a few days.'),
                            actions: [
                              TextButton(
                                child: Text('No'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: Text('Yes'),
                                onPressed: () {
                                  Database.requestAccountDeletion(widget.user);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      'Account deletion request submitted.',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant),
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant,
                                  ));
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  },
                  label: Text('Delete Account'),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                ),
              ),
            ),
          ),
        ],
      ),
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
          if (value != null) {
            setState(() {
              _teamNumber = value;
            });
            Database.updateUserTeam(widget.user, value);
          }
        },
      ),
    );
  }

  TextEditingController _getController(String text) {
    return TextEditingController(text: text)
      ..selection =
          TextSelection.fromPosition(TextPosition(offset: text.length));
  }
}
