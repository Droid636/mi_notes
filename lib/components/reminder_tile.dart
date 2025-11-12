import 'package:flutter/material.dart';
import '../models/reminder_model.dart';

class ReminderTile extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ReminderTile({
    super.key,
    required this.reminder,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          reminder.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Programado para: ${reminder.scheduledAt}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
