import 'package:intl/intl.dart';

// Formatear solo la fecha: 11/11/2025
String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

// Formatear fecha y hora: 11/11/2025 14:30
String formatDateTime(DateTime date) {
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}
