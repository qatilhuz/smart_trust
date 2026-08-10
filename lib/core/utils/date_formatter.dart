import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime dateTime) {
    return DateFormat.yMMMMd().format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat.yMMMMd().add_jm().format(dateTime);
  }
}
