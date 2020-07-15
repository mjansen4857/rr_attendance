import 'package:flutter/material.dart';
import 'package:rr_attendance/color_palette.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Leaderboard'),
          backgroundColor: Colors.indigo,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(
                text: '3015',
              ),
              Tab(
                text: '2716',
              )
            ],
          ),
        ),
        backgroundColor: darkBG,
        body: TabBarView(
          children: <Widget>[build3015Tab(), build2716Tab()],
        ),
      ),
    );
  }

  Widget build3015Tab() {
    return Container(
      child: Center(
        child: Text('3015 Leaderboard'),
      ),
    );
  }

  Widget build2716Tab() {
    return Container(
      child: Center(
        child: Text('2716 Leaderboard'),
      ),
    );
  }
}
