import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';
import 'package:rr_attendance/widgets/control_panel_card.dart';
import 'package:rr_attendance/widgets/request_card.dart';

class ControlPanelPage extends StatefulWidget {
  final String resetPassword;

  ControlPanelPage({
    super.key,
    required this.resetPassword,
  });

  @override
  State<ControlPanelPage> createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends State<ControlPanelPage> {
  int? _numUsers;
  int? _numClockedIn;
  List<TimeRequest> _timeRequests = [];

  @override
  void initState() {
    super.initState();

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'control_panel');

    Database.getNumUsers().then((numUsers) {
      setState(() {
        _numUsers = numUsers;
      });
    });

    Database.getNumClockedIn().then((numClockedIn) {
      setState(() {
        _numClockedIn = numClockedIn;
      });
    });

    Database.getTimeRequests().then((requests) {
      setState(() {
        _timeRequests = requests;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildUserCards(),
            SizedBox(height: 12),
            Text(
              'Time Change Requests',
              style: TextStyle(fontSize: 20),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Divider(),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (TimeRequest request in _timeRequests)
                    RequestCard(
                      request: request,
                      removeRequestCallback: (TimeRequest request) {
                        setState(() {
                          _timeRequests.remove(request);
                        });
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  _showResetDialog(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Reset All Hours',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  primary: colorScheme.primaryContainer,
                  onPrimary: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCards() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ControlPanelCard(
              data: _numUsers,
              label: 'Users',
            ),
            flex: 1,
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: ControlPanelCard(
              data: _numClockedIn,
              label: 'Clocked In',
            ),
            flex: 1,
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        ColorScheme colorScheme = Theme.of(context).colorScheme;

        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text('Reset All Hours'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onSubmitted: (val) async {
                  Navigator.of(context).pop();

                  if (val == widget.resetPassword) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Resetting hours...'),
                      ),
                    );
                    await Database.resetAllHours();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hours reset'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Invalid reset password'),
                      ),
                    );
                  }
                },
                autofocus: true,
                keyboardAppearance: colorScheme.brightness,
                controller: controller,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                  labelText: 'Reset Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                if (controller.text == widget.resetPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Resetting hours...'),
                    ),
                  );
                  await Database.resetAllHours();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hours reset'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid reset password'),
                    ),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
