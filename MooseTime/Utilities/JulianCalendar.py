#JulianCalendar.py
# Julian Calendar calculator 

from datetime import datetime, timedelta

class JulianCalendar:

    @staticmethod
    def date_to_julian(date: datetime) -> int:
        return date.timetuple().tm_yday

    @staticmethod
    def julian_to_date(year: int, julian_day: int) -> datetime:
        return datetime(year, 1, 1) + timedelta(days=julian_day - 1)