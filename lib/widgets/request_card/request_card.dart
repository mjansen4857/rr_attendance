import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequestCard extends StatelessWidget {
  final DocumentSnapshot requestSnapshot;

  RequestCard(this.requestSnapshot);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(requestSnapshot.data['name']),
              subtitle: Text(requestSnapshot.data['changeDate']),
            ),
          ],
        ),
      ),
    );
  }
}
