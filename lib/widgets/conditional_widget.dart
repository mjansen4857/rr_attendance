import 'package:flutter/material.dart';

class ConditionalWidget extends StatelessWidget {
  final bool condition;
  final Widget? ifTrue;
  final Widget? ifFalse;

  const ConditionalWidget(
      {required this.condition, this.ifTrue, this.ifFalse, super.key});

  @override
  Widget build(BuildContext context) {
    if (condition) {
      return ifTrue ?? Container();
    } else {
      return ifFalse ?? Container();
    }
  }
}
