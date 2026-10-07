class JulianCalendar {
  static int dateToJulian(DateTime date) {
    final currentDate = DateTime.utc(
      date.year,
      date.month,
      date.day,
    );

    final startOfYear = DateTime.utc(
      date.year,
      1,
      1,
    );

    return currentDate.difference(startOfYear).inDays + 1;
  }

static DateTime julianToDate(
  int year,
  int julianDay,
) {
  final maxDay = isLeapYear(year) ? 366 : 365;

  if (julianDay < 1 || julianDay > maxDay) {
    throw ArgumentError(
      'Julian day must be between 1 and $maxDay.',
    );
  }

  return DateTime(
    year,
    1,
    julianDay,
  );
}

  static bool isLeapYear(int year) {
    return year % 4 == 0 &&
        (year % 100 != 0 || year % 400 == 0);
  }
}