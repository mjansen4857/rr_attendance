import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';
import 'package:rr_attendance/widgets/request_card/request_card.dart';

class RequestsPage extends StatefulWidget {
  final Database db;

  RequestsPage({this.db});

  @override
  State<StatefulWidget> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  List<RequestCard> _requestCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    widget.db.getTimeRequests().then((querySnapshot) {
      List<DocumentSnapshot> docs = querySnapshot.documents;
      List<RequestCard> cards = [];

      for (var doc in docs) {
        cards.add(RequestCard(
          doc,
          db: widget.db,
          removeCardCallback: _removeCardCallback,
        ));
      }

      setState(() {
        _isLoading = false;
        _requestCards = cards;
      });
    });
  }

  void _removeCardCallback(RequestCard card) {
    setState(() {
      List<RequestCard> cards = List.from(_requestCards);
      cards.remove(card);
      _requestCards = cards;
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
        Center(
          child: ListView(
            padding: EdgeInsets.all(5),
            children: _requestCards,
          ),
        ),
        showLoading(),
      ],
    );
  }
}
