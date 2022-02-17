import 'package:intl/intl.dart';

///class containing helpers to use for DateTime object.

class DateTimeHelper {
  ///converts DateTime object to "11:18 AM" format.
  static String formatDateTimeToTimeString(DateTime? dateTime) {
    if (dateTime != null) {
      return DateFormat('HH:mm a').format(dateTime);
    }
    return "";
  }

  /// converts DateTime object to "Thu 17 Feb 2022" format
  static String formatDateTimeToDayMonthYearString(DateTime? dateTime) {
    if (dateTime != null) {
      return '${DateFormat('EE dd MMM yyyy').format(dateTime)}';
    }
    return "";
  }

  /// converts DateTime object to DateTime only represent the day of the year, DateTime(year, month, day)
  static DateTime formatDateTimeToYearMonthDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
