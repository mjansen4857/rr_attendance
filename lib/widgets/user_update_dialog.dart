import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';

class UserUpdateDialog extends StatefulWidget {
  final User user;

  UserUpdateDialog({required this.user, super.key});

  @override
  State<UserUpdateDialog> createState() => _UserUpdateDialogState();
}

class _UserUpdateDialogState extends State<UserUpdateDialog> {
  TextEditingController? _nameController;
  int? _teamNumber;

  @override
  void initState() {
    super.initState();

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

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text('Update Name & Team'),
      actions: [
        TextButton(
          onPressed: () {
            if (_nameController != null &&
                _teamNumber != null &&
                _nameController!.text.length > 0) {
              Database.updateUserName(widget.user, _nameController!.text);
              Database.updateUserTeam(widget.user, _teamNumber!);
              Navigator.of(context).pop();
            }
          },
          child: Text('Confirm'),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(8, 4, 8, 4),
              labelText: 'Full Name',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          SizedBox(height: 12),
          _buildTeamDropdown(),
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
