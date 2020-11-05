import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TimeCard extends StatelessWidget {
  final DocumentSnapshot dateSnapshot;
  DateTime cardDate;

  TimeCard(this.dateSnapshot) {
    List<String> dateValues = dateSnapshot.documentID.split('-');
    this.cardDate = DateTime(int.parse(dateValues[0]), int.parse(dateValues[1]),
        int.parse(dateValues[2]));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(cardDate.month.toString() +
                '/' +
                cardDate.day.toString() +
                '/' +
                cardDate.year.toString()),
            subtitle:
                Text(dateSnapshot.data['hours'].toStringAsFixed(1) + ' hours'),
            trailing: IconButton(
              icon: Icon(
                Icons.report,
                color: Colors.grey[300],
              ),
              onPressed: () {
                //TODO
              },
            ),
          ),
        ],
      ),
    );
  }
}
