import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../utils/date_utils.dart';

class ReminderTile extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback onTap;
  final Widget? trailing; // 🔹 Nuevo parámetro

  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(reminder.title),
      subtitle: Text(formatDateTime(reminder.scheduledAt)),
      onTap: onTap,
      trailing: trailing, // Ahora se puede pasar el PopupMenuButton
    );
  }
}
