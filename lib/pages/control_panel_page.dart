import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/cloud_functions.dart';
import 'package:rr_attendance/services/database.dart';
import 'package:rr_attendance/widgets/stats_displays/number_stat.dart';

class ControlPanelPage extends StatefulWidget {
  final Database db;

  ControlPanelPage({this.db});

  @override
  State<StatefulWidget> createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends State<ControlPanelPage> {
  bool _isLoading = true;
  int _totalUsers = 0;
  int _clockedInUsers = 0;

  @override
  void initState() {
    super.initState();
    widget.db.getTotalUsers().then((totalUsers) {
      widget.db.getClockedInUsers().then((clockedIn) {
        setState(() {
          _isLoading = false;
          _totalUsers = totalUsers;
          _clockedInUsers = clockedIn;
        });
      });
    });
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
          child: CupertinoScrollbar(
            child: ListView(
              padding: EdgeInsets.all(12),
              children: [
                Center(
                  child: Text(
                    'User Stats',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
                Divider(),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Spacer(flex: 1),
                    Expanded(
                      flex: 10,
                      child: NumberStat(_totalUsers, 'Users'),
                    ),
                    Spacer(flex: 2),
                    Expanded(
                      flex: 10,
                      child: NumberStat(_clockedInUsers, 'Clocked In'),
                    ),
                    Spacer(flex: 1),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Center(
                    child: Text(
                      'Database',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                Divider(),
                RaisedButton(
                  onPressed: () {
                    // Disable button so that it can only be pressed in a debug environment
                    // _showResetHoursDialog();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Reset Hours',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
        ),
        showLoading(),
      ],
    );
  }

  Future<void> _showResetHoursDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Hours Confirmation'),
          content: Text(
              'Are you sure you want to reset all hours? This can not be undone!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isLoading = true;
                  CloudFunctions.resetHours().then((value) {
                    setState(() {
                      _isLoading = false;
                    });
                  });
                });
              },
              child: Text(
                'Confirm',
              ),
            ),
          ],
        );
      },
    );
  }
}
