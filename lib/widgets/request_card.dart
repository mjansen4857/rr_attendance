import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';

class RequestCard extends StatelessWidget {
  final TimeRequest request;
  final Function(TimeRequest) removeRequestCallback;

  const RequestCard(
      {required this.request, required this.removeRequestCallback, super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 8,
        child: ListTile(
          title: Text(request.userName),
          subtitle: Text(
              '${request.requestDate.month}/${request.requestDate.day}/${request.requestDate.year}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(request.prevHours.toStringAsFixed(2)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(
                  Icons.arrow_forward,
                  size: 20,
                ),
              ),
              Text(request.newHours.toStringAsFixed(2)),
              SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  Database.deleteTimeRequest(request);
                  removeRequestCallback(request);
                },
                icon: Icon(
                  Icons.clear,
                  color: colorScheme.error,
                ),
              ),
              IconButton(
                onPressed: () {
                  Database.approveTimeRequest(request);
                  removeRequestCallback(request);
                },
                icon: Icon(
                  Icons.check,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
