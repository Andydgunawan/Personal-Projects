import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))

from datetime import datetime
from Utilities.JulianCalendar import JulianCalendar

def test_date_to_julian():
    assert JulianCalendar.date_to_julian(
        datetime(2026, 1, 1)
    ) == 1

    assert JulianCalendar.date_to_julian(
        datetime(2026, 10, 1)
    ) == 274

    assert JulianCalendar.date_to_julian(
        datetime(2026, 12, 31)
    ) == 365

    print("Date to Julian: PASSED")


def test_date_to_julian_leap_year():
    assert JulianCalendar.date_to_julian(
        datetime(2028, 2, 29)
    ) == 60

    assert JulianCalendar.date_to_julian(
        datetime(2028, 12, 31)
    ) == 366

    print("Date to Julian Leap Year: PASSED")


def test_julian_to_date():
    assert JulianCalendar.julian_to_date(
        2026, 1
    ) == datetime(2026, 1, 1)

    assert JulianCalendar.julian_to_date(
        2026, 274
    ) == datetime(2026, 10, 1)

    assert JulianCalendar.julian_to_date(
        2026, 365
    ) == datetime(2026, 12, 31)

    print("Julian to Date: PASSED")


def test_julian_to_date_leap_year():
    assert JulianCalendar.julian_to_date(
        2028, 60
    ) == datetime(2028, 2, 29)

    assert JulianCalendar.julian_to_date(
        2028, 366
    ) == datetime(2028, 12, 31)

    print("Julian to Date Leap Year: PASSED")


test_date_to_julian()
test_date_to_julian_leap_year()
test_julian_to_date()
test_julian_to_date_leap_year()

print("\nALL JULIAN CALENDAR TESTS PASSED")