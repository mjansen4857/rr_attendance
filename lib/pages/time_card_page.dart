import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';
import 'package:rr_attendance/widgets/time_card/time_card.dart';

class TimeCardPage extends StatefulWidget {
  final User user;
  final Database db;

  TimeCardPage({this.user, this.db});

  @override
  State<StatefulWidget> createState() => _TimeCardPageState();
}

class _TimeCardPageState extends State<TimeCardPage> {
  List<TimeCard> _timeCards = [];
  String _totalHours = '0';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    widget.db.getTimecardDocs(widget.user).then((querySnapshot) {
      widget.db.getTotalHours(widget.user).then((value) {
        List<TimeCard> cards = [];
        for (var doc in querySnapshot.documents) {
          cards.add(TimeCard(
            db: widget.db,
            user: widget.user,
            dateSnapshot: doc,
          ));
        }
        cards.sort((a, b) {
          return a.cardDate.compareTo(b.cardDate);
        });
        setState(() {
          _timeCards = cards;
          _totalHours = value.toStringAsFixed(1);
          _isLoading = false;
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
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Total Hours: $_totalHours',
                    style: TextStyle(color: Colors.white, fontSize: 36),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoScrollbar(
                  child: ListView(
                    padding: EdgeInsets.all(5),
                    children: _timeCards,
                  ),
                ),
              ),
            ],
          ),
        ),
        showLoading(),
      ],
    );
  }
}
