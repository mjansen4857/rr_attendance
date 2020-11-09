import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';

class LeaderboardPage extends StatefulWidget {
  final User user;
  final Database db;

  LeaderboardPage({this.user, this.db});

  @override
  State<StatefulWidget> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  bool _isLoading = true;
  List<DocumentSnapshot> _3015Docs = [];
  List<DocumentSnapshot> _2716Docs = [];
  double _3015Total = 0;
  double _2716Total = 0;

  @override
  void initState() {
    super.initState();
    widget.db.getAllUserDocsFromTeam(3015).then((value3015) {
      widget.db.getAllUserDocsFromTeam(2716).then((value2716) {
        setState(() {
          _3015Docs = value3015.docs;
          _3015Docs.forEach((element) {
            _3015Total += element.data()['total_hours'];
          });
          _2716Docs = value2716.docs;
          _2716Docs.forEach((element) {
            _2716Total += element.data()['total_hours'];
          });
          _isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        TabBarView(children: <Widget>[build3015Tab(), build2716Tab()]),
        showLoading(),
      ],
    );
  }

  Widget build3015Tab() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Material(
            elevation: 5,
            color: Color(0xff343434),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Center(
                child: Text(
                  'Team Total: ${_3015Total.toStringAsFixed(1)} hours',
                  style: TextStyle(color: Colors.white, fontSize: 28),
                ),
              ),
            ),
          ),
          build3015List(),
        ],
      ),
    );
  }

  Widget build2716Tab() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Material(
            elevation: 5,
            color: Color(0xff343434),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Center(
                child: Text(
                  'Team Total: ${_2716Total.toStringAsFixed(1)} hours',
                  style: TextStyle(color: Colors.white, fontSize: 28),
                ),
              ),
            ),
          ),
          build2716List(),
        ],
      ),
    );
  }

  Widget build3015List() {
    return Expanded(
      child: CupertinoScrollbar(
        child: ListView(
          padding: EdgeInsets.fromLTRB(3, 5, 3, 3),
          children: build3015Entries(),
        ),
      ),
    );
  }

  Widget build2716List() {
    return Expanded(
      child: CupertinoScrollbar(
        child: ListView(
          padding: EdgeInsets.all(3),
          children: build2716Entries(),
        ),
      ),
    );
  }

  List<Widget> build3015Entries() {
    List<Widget> entries = [];
    for (int i = 0; i < _3015Docs.length; i++) {
      entries.add(Card(
        child: ListTile(
          leading: Text(
            (i + 1).toString() + '.',
            style: TextStyle(fontSize: 18),
          ),
          title: Text(
            _3015Docs[i].data()['name'],
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          trailing: Text(
              _3015Docs[i].data()['total_hours'].toStringAsFixed(1) + ' hours'),
        ),
      ));
    }
    return entries;
  }

  List<Widget> build2716Entries() {
    List<Widget> entries = [];
    for (int i = 0; i < _2716Docs.length; i++) {
      entries.add(Card(
        child: ListTile(
          leading: Text(
            (i + 1).toString() + '.',
            style: TextStyle(fontSize: 18),
          ),
          title: Text(
            _2716Docs[i].data()['name'],
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          trailing: Text(
              _2716Docs[i].data()['total_hours'].toStringAsFixed(1) + ' hours'),
        ),
      ));
    }
    return entries;
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
}
