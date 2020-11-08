import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';

class RequestCard extends StatelessWidget {
  final Database db;
  final DateTime date;
  final String hours;
  final String name;
  final String uid;
  final Function(RequestCard) removeCardCallback;

  RequestCard(DocumentSnapshot requestSnapshot,
      {this.db, this.removeCardCallback})
      : date = requestSnapshot.data()['changeDate'].toDate(),
        hours = requestSnapshot.data()['newHours'].toString(),
        name = requestSnapshot.data()['name'].toString(),
        uid = requestSnapshot.data()['user'];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(name),
            subtitle: Text(date.month.toString() +
                '/' +
                date.day.toString() +
                '/' +
                date.year.toString() +
                ' - ' +
                hours +
                ' hours'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    db.deleteTimeRequest(uid, date, hours).then((value) {
                      removeCardCallback(this);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    db.approveTimeRequest(uid, date, hours).then((value) {
                      removeCardCallback(this);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
