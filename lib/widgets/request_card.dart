import 'package:flutter/material.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        // color: colorScheme.surfaceVariant,
        elevation: 8,
        child: Container(height: 64),
      ),
    );
  }
}
