import 'package:flutter_test/flutter_test.dart';

import 'package:moose_time/utilities/julian_calendar.dart';

void main() {
  test('Date to Julian conversion is correct', () {
    expect(
      JulianCalendar.dateToJulian(
        DateTime(2026, 1, 1),
      ),
      1,
    );

    expect(
      JulianCalendar.dateToJulian(
        DateTime(2026, 10, 1),
      ),
      274,
    );

    expect(
      JulianCalendar.dateToJulian(
        DateTime(2026, 12, 31),
      ),
      365,
    );
  });

  test('Date to Julian conversion handles leap years', () {
    expect(
      JulianCalendar.dateToJulian(
        DateTime(2028, 2, 29),
      ),
      60,
    );

    expect(
      JulianCalendar.dateToJulian(
        DateTime(2028, 12, 31),
      ),
      366,
    );
  });

  test('Julian to Date conversion is correct', () {
    expect(
      JulianCalendar.julianToDate(
        2026,
        1,
      ),
      DateTime(2026, 1, 1),
    );

    expect(
      JulianCalendar.julianToDate(
        2026,
        274,
      ),
      DateTime(2026, 10, 1),
    );

    expect(
      JulianCalendar.julianToDate(
        2026,
        365,
      ),
      DateTime(2026, 12, 31),
    );
  });

  test('Julian to Date conversion handles leap years', () {
    expect(
      JulianCalendar.julianToDate(
        2028,
        60,
      ),
      DateTime(2028, 2, 29),
    );

    expect(
      JulianCalendar.julianToDate(
        2028,
        366,
      ),
      DateTime(2028, 12, 31),
    );
  });

  test('Julian calendar rejects invalid days in a normal year', () {
    expect(
      () => JulianCalendar.julianToDate(
        2026,
        0,
      ),
      throwsArgumentError,
    );

    expect(
      () => JulianCalendar.julianToDate(
        2026,
        366,
      ),
      throwsArgumentError,
    );
  });

  test('Julian calendar rejects invalid days in a leap year', () {
    expect(
      () => JulianCalendar.julianToDate(
        2028,
        367,
      ),
      throwsArgumentError,
    );
  });
}