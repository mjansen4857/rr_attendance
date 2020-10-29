import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';

class LeaderboardPage extends StatefulWidget {
  final FirebaseUser user;
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
          _3015Docs = value3015.documents;
          _3015Docs.forEach((element) {
            _3015Total += element.data['total_hours'];
          });
          _3015Docs.sort((a, b) {
            double aHours = a.data['total_hours'].toDouble();
            double bHours = b.data['total_hours'].toDouble();
            return bHours.compareTo(aHours);
          });
          _2716Docs = value2716.documents;
          _2716Docs.forEach((element) {
            _2716Total += element.data['total_hours'];
          });
          _2716Docs.sort((a, b) {
            double aHours = a.data['total_hours'].toDouble();
            double bHours = b.data['total_hours'].toDouble();
            return bHours.compareTo(aHours);
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // title: Text('Leaderboard'),
          // backgroundColor: Colors.indigo,
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back),
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          // ),
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
        // backgroundColor: darkBG,
        body: Stack(
          children: <Widget>[
            TabBarView(children: <Widget>[build3015Tab(), build2716Tab()]),
            showLoading(),
          ],
        ),
      ),
    );
  }

  Widget build3015Tab() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Total Hours: ${_3015Total.toStringAsFixed(1)}',
                style: TextStyle(color: Colors.white, fontSize: 36),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: build3015Table(),
          )
        ],
      ),
    );
  }

  Widget build2716Tab() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Total Hours: ${_2716Total.toStringAsFixed(1)}',
                style: TextStyle(color: Colors.white, fontSize: 36),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: build2716Table(),
          )
        ],
      ),
    );
  }

  Widget build3015Table() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        sortColumnIndex: 1,
        sortAscending: true,
        columns: <DataColumn>[
          DataColumn(
              label: Text(
            'Name',
            style: TextStyle(
                color: Colors.grey[200],
                fontSize: 26,
                fontWeight: FontWeight.bold),
          )),
          DataColumn(
            label: Text(
              'Hours',
              style: TextStyle(
                  color: Colors.grey[200],
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
            numeric: true,
          )
        ],
        rows: build3015DataRows(),
      ),
    );
  }

  List<DataRow> build3015DataRows() {
    List<DataRow> dataRows = [];
    _3015Docs.forEach((element) {
      double hours = element.data['total_hours'].toDouble();
      String name = element.data['name'];
      dataRows.add(DataRow(cells: <DataCell>[
        DataCell(Text(
          name,
          style: TextStyle(color: Colors.grey[300], fontSize: 20),
        )),
        DataCell(Text(
          hours.toStringAsFixed(1),
          style: TextStyle(color: Colors.grey[300], fontSize: 20),
        ))
      ]));
    });
    return dataRows;
  }

  Widget build2716Table() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        sortColumnIndex: 1,
        columns: <DataColumn>[
          DataColumn(
              label: Text(
            'Name',
            style: TextStyle(
                color: Colors.grey[200],
                fontSize: 26,
                fontWeight: FontWeight.bold),
          )),
          DataColumn(
              label: Text(
                'Hours',
                style: TextStyle(
                    color: Colors.grey[200],
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              numeric: true)
        ],
        rows: build2716DataRows(),
      ),
    );
  }

  List<DataRow> build2716DataRows() {
    List<DataRow> dataRows = [];
    _2716Docs.forEach((element) {
      double hours = element.data['total_hours'].toDouble();
      String name = element.data['name'];
      dataRows.add(DataRow(cells: <DataCell>[
        DataCell(Text(
          name,
          style: TextStyle(color: Colors.grey[300], fontSize: 20),
        )),
        DataCell(Text(
          hours.toStringAsFixed(1),
          style: TextStyle(color: Colors.grey[300], fontSize: 20),
        ))
      ]));
    });
    return dataRows;
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
