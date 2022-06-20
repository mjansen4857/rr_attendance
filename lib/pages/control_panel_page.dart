import 'package:flutter/material.dart';

class ControlPanelPage extends StatefulWidget {
  ControlPanelPage({Key? key}) : super(key: key);

  @override
  State<ControlPanelPage> createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends State<ControlPanelPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Control Panel'),
    );
  }
}
