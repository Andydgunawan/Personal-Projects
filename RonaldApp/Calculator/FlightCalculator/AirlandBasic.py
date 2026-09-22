#AirlandBasic.py
#parent class for airland basic calculator, child of flight parent calc class
from datetime import timedelta
from .FlightParentCalculator import FlightParentCalculator

class AirlandBasic(FlightParentCalculator):
    alert_offset = timedelta(hours=3, minutes=45)
    def __init__(self, zulu_takeoff_time, showtime_adjustment=timedelta(minutes=60),
                 stationtime_adjustment=timedelta(minutes=45),
                 qualifying_leg=False):

        super().__init__(
            zulu_takeoff_time,
            showtime_adjustment,
            stationtime_adjustment,
            augment_variable=False,
            qualifying_leg=qualifying_leg
        )