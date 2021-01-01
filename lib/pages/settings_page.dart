import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';

class SettingsPage extends StatefulWidget {
  final User user;
  final Database db;

  SettingsPage({this.user, this.db});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = true;
  String _name = '';
  int _teamNumber;
  var _nameController;

  @override
  void initState() {
    super.initState();
    _name = widget.user.displayName;
    _nameController = TextEditingController(text: _name);
    widget.db.getTeamNumber(widget.user).then((value) {
      setState(() {
        _isLoading = false;
        _teamNumber = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Visibility(
          child: Center(child: CircularProgressIndicator()),
          visible: _isLoading,
        ),
        CupertinoScrollbar(
          child: ListView(
            padding: EdgeInsets.only(top: 8),
            children: [
              ListTile(
                title: Text(
                  'Name',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _name,
                  style: TextStyle(fontSize: 17),
                ),
                // leading: Icon(Icons.account_circle),
                trailing: Icon(Icons.edit),
                onTap: () {
                  _changeNameDialog(context);
                },
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Team Number',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _teamNumber.toString(),
                  style: TextStyle(fontSize: 17),
                ),
                // leading: Icon(Icons.assignment),
                trailing: Icon(Icons.edit),
                onTap: () {
                  _changeTeamDialog(context);
                },
              ),
              Divider(),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _changeNameDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext builderContext) {
        return AlertDialog(
          title: Text('Edit Name'),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: TextField(
                    autofocus: true,
                    keyboardType: TextInputType.name,
                    keyboardAppearance: Brightness.dark,
                    cursorColor: Colors.white,
                    controller: _nameController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      hintText: 'Full Name',
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[400],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'SAVE',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context);
                widget.user.updateProfile(displayName: _nameController.text);
                widget.db.updateUserName(widget.user, _nameController.text);
                setState(() {
                  _name = _nameController.text;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeTeamDialog(BuildContext context) async {
    int num = _teamNumber;
    await showDialog(
      context: context,
      builder: (BuildContext builderContext) {
        return AlertDialog(
          title: Text('Change Team'),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: DropdownButtonFormField<int>(
                    onChanged: (int newVal) {
                      num = newVal;
                    },
                    value: _teamNumber,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
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
                  ),
                  // child: TextField(
                  //   autofocus: true,
                  //   keyboardType: TextInputType.name,
                  //   keyboardAppearance: Brightness.dark,
                  //   cursorColor: Colors.white,
                  //   controller: _nameController,
                  //   decoration: InputDecoration(
                  //     contentPadding: EdgeInsets.all(10),
                  //     hintText: 'Full Name',
                  //     hintStyle: TextStyle(
                  //       fontSize: 18,
                  //       color: Colors.grey[400],
                  //     ),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //       borderSide: BorderSide(
                  //         width: 0,
                  //         style: BorderStyle.none,
                  //       ),
                  //     ),
                  //     filled: true,
                  //   ),
                  // ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'SAVE',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context);
                widget.db.updateUserTeam(widget.user, num);
                setState(() {
                  _teamNumber = num;
                });
              },
            ),
          ],
        );
      },
    );
  }
}
