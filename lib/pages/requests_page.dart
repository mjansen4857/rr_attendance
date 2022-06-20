import 'package:flutter/material.dart';

class RequestsPage extends StatefulWidget {
  RequestsPage({Key? key}) : super(key: key);

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Requests Page'),
    );
  }
}
