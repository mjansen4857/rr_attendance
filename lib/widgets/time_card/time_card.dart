import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';

// ignore: must_be_immutable
class TimeCard extends StatefulWidget {
  final Database db;
  final User user;
  final DocumentSnapshot dateSnapshot;
  DateTime cardDate;

  TimeCard({this.db, this.user, this.dateSnapshot}) {
    List<String> dateValues = dateSnapshot.id.split('-');
    this.cardDate = DateTime(int.parse(dateValues[0]), int.parse(dateValues[1]),
        int.parse(dateValues[2]));
  }

  @override
  State<StatefulWidget> createState() => _TimeCardState();
}

class _TimeCardState extends State<TimeCard> {
  var _requestedHoursController;
  String _dateText;

  @override
  void initState() {
    super.initState();
    _requestedHoursController = TextEditingController();
    _dateText = widget.cardDate.month.toString() +
        '/' +
        widget.cardDate.day.toString() +
        '/' +
        widget.cardDate.year.toString();
  }

  @override
  void dispose() {
    _requestedHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(_dateText),
            subtitle: Text(
                widget.dateSnapshot.data()['hours'].toStringAsFixed(1) +
                    ' hours'),
            trailing: IconButton(
              icon: Icon(
                Icons.report,
                color: Colors.grey[300],
              ),
              onPressed: () {
                _timeRequestDialog(context);
              },
              tooltip: 'Request Time Change',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _timeRequestDialog(BuildContext context) async {
    _requestedHoursController.clear();
    await showDialog(
      context: context,
      builder: (BuildContext builderContext) {
        return AlertDialog(
          title: Text('Request Time Change for ' + _dateText),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: TextField(
                    autofocus: true,
                    keyboardType: TextInputType.numberWithOptions(
                        signed: false, decimal: true),
                    keyboardAppearance: Brightness.dark,
                    cursorColor: Colors.white,
                    controller: _requestedHoursController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      hintText: 'Requested Hours',
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
                'SUBMIT',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context);
                double requestedHours =
                    double.parse(_requestedHoursController.text);
                widget.db.addTimeRequest(
                    widget.user, widget.cardDate, requestedHours);
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Time change request submitted.',
                      style: TextStyle(color: Colors.white),
                    ),
                    duration: Duration(milliseconds: 2000),
                    backgroundColor: Colors.grey[900],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
