import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';

class LeaderboardPage extends StatefulWidget {
  final User user;

  LeaderboardPage({required this.user, super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  var _entries = [];

  @override
  void initState() {
    super.initState();

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'leaderboard');

    Database.getAllLeaderboardDocs().then((entries) {
      setState(() {
        _entries = entries;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    for (int i = 0; i < _entries.length; i++)
                      Card(
                        color: _entries[i].name == widget.user.displayName
                            ? colorScheme.surfaceVariant
                            : colorScheme.surface,
                        child: ListTile(
                          leading: Text('${i + 1}.'),
                          title: Text(_entries[i].name),
                          subtitle: Text('${_entries[i].team}'),
                          trailing:
                              Text('${_entries[i].totalHours.round()} hours'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
