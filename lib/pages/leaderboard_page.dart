import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  LeaderboardPage({Key? key}) : super(key: key);

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Leaderboard'),
    );
  }
}
