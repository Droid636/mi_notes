import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../utils/date_utils.dart';

class ReminderTile extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback onTap;

  const ReminderTile({super.key, required this.reminder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(reminder.title),
      subtitle: Text(formatDateTime(reminder.scheduledAt)),
      onTap: onTap,
    );
  }
}
