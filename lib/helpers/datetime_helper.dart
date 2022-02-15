import 'package:intl/intl.dart';

class DateTimeHelper {
  static String formatDateTimeToTimeString(DateTime? dateTime) {
    if (dateTime != null) {
      return DateFormat('HH:mm a').format(dateTime);
    }
    return "";
  }

  static String formatDateTimeToDayMonthYearString(DateTime? dateTime) {
    if (dateTime != null) {
      return '${DateFormat('EE dd MMM yyyy').format(dateTime)}';
    }
    return "";
  }

  static DateTime formatDateTimeToYearMonthDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
