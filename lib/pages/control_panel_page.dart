import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ControlPanelPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends State<ControlPanelPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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
          child: CupertinoScrollbar(
            child: ListView(
              padding: EdgeInsets.all(8),
              children: [
                RaisedButton(
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Reset Hours',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
        ),
        showLoading(),
      ],
    );
  }
}
