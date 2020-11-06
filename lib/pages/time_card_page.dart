import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';
import 'package:rr_attendance/widgets/time_card/time_card.dart';

class TimeCardPage extends StatefulWidget {
  final FirebaseUser user;
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

  // Widget buildDataTable() {
  //   return SingleChildScrollView(
  //     scrollDirection: Axis.vertical,
  //     child: DataTable(
  //       sortColumnIndex: 0,
  //       columns: <DataColumn>[
  //         DataColumn(
  //             label: Text(
  //           'Date',
  //           style: TextStyle(
  //               color: Colors.grey[200],
  //               fontSize: 26,
  //               fontWeight: FontWeight.bold),
  //         )),
  //         DataColumn(
  //             label: Text(
  //               'Hours',
  //               style: TextStyle(
  //                   color: Colors.grey[200],
  //                   fontSize: 26,
  //                   fontWeight: FontWeight.bold),
  //             ),
  //             numeric: true)
  //       ],
  //       rows: buildDataRows(),
  //     ),
  //   );
  // }

  // List<DataRow> buildDataRows() {
  //   List<DataRow> dataRows = [];
  //   _timecardDocs.forEach((element) {
  //     double hours = element.data['hours'];
  //     dataRows.add(DataRow(cells: <DataCell>[
  //       DataCell(Text(
  //         element.documentID,
  //         style: TextStyle(color: Colors.grey[300], fontSize: 20),
  //       )),
  //       DataCell(Text(
  //         hours.toStringAsFixed(1),
  //         style: TextStyle(color: Colors.grey[300], fontSize: 20),
  //       ))
  //     ]));
  //   });
  //   return dataRows;
  // }

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
                child: ListView(
                  padding: EdgeInsets.all(5),
                  children: _timeCards,
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
