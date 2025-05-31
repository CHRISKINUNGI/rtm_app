import 'package:flutter/material.dart';
import '../models/visit.dart';

class VisitCard extends StatelessWidget {
  final Visit visit;

  const VisitCard({
    Key? key,
    required this.visit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(visit.customerName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${visit.status}'),
            Text('Location: ${visit.location}'),
            Text('Activities: ${visit.activitiesDone.join(", ")}'),
            if (visit.notes.isNotEmpty) Text('Notes: ${visit.notes}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              visit.visitDate.toString().split(' ')[0],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(visit.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                visit.status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
