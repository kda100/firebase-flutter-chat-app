import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeHelper {
  static DateTime findStartOfWeek(DateTime dateTime) {
    return dateTime.subtract(
      Duration(days: dateTime.weekday - 1),
    );
  }

  static DateTime findEndOfWeek(DateTime dateTime) {
    return dateTime.add(
      Duration(
        days: DateTime.daysPerWeek - dateTime.weekday,
        milliseconds: 86399999,
      ),
    );
  }

  static DateTime today() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static Future<DateTime?> getDate({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDatePickerMode: DatePickerMode.day,
      locale: Locale("en", "GB"),
    );
  }

  static String formatDateTimeToTimeString(DateTime? dateTime) {
    if (dateTime != null) {
      return DateFormat('HH:mm a').format(dateTime);
    }
    return "";
  }

  static DateTime? formatDDMMYYYYStringToDateTime(String? dateTime) {
    if (dateTime != null && dateTime.isNotEmpty) {
      DateFormat format = DateFormat("dd/MM/yyyy");
      return format.parse(dateTime);
    }
    return null;
  }

  static String formatDateTimeToTimeDayMonthYearString(DateTime? dateTime) {
    if (dateTime != null) {
      return '${DateFormat('HH:mm a - EE dd MMMM yyyy').format(dateTime)}';
    }
    return "";
  }

  static String formatDateTimeToDDMMYYYYString(DateTime? dateTime) {
    if (dateTime != null) {
      return '${DateFormat('dd/MM/yyyy').format(dateTime)}';
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

  static int? calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth != null) {
      DateTime currentDate = DateTime.now();
      int age = currentDate.year - dateOfBirth.year;
      int month1 = currentDate.month;
      int month2 = dateOfBirth.month;
      if (month2 > month1) {
        age--;
      } else if (month1 == month2) {
        int day1 = currentDate.day;
        int day2 = dateOfBirth.day;
        if (day2 > day1) {
          age--;
        }
      }
      return age;
    }
  }
}
