import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';
import 'package:rr_attendance/widgets/control_panel_card.dart';
import 'package:rr_attendance/widgets/request_card.dart';

class ControlPanelPage extends StatefulWidget {
  ControlPanelPage({super.key});

  @override
  State<ControlPanelPage> createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends State<ControlPanelPage> {
  int? _numUsers;
  int? _numClockedIn;

  @override
  void initState() {
    super.initState();

    Database.getNumUsers().then((numUsers) {
      Database.getNumClockedIn().then((numClockedIn) {
        setState(() {
          _numUsers = numUsers;
          _numClockedIn = numClockedIn;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
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
              RequestCard(),
              RequestCard(),
              RequestCard(),
              RequestCard(),
              RequestCard(),
              RequestCard(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: ElevatedButton(
            onPressed: () {},
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
}
