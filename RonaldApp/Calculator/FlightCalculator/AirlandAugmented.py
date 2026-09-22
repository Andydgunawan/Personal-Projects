#AirlandAugmented.py
#parent class for airland augmented calculator, child of flight parent calc class
from datetime import timedelta
from .FlightParentCalculator import FlightParentCalculator as FlightParentCalc

class AirlandAugmented(FlightParentCalc):
    alert_offset = timedelta(hours=3, minutes=45)
    def __init__(self, zulu_takeoff_time, showtime_adjustment=timedelta(minutes=60),
                 stationtime_adjustment=timedelta(minutes=45),
                 qualifying_leg=False):

        super().__init__(
            zulu_takeoff_time,
            showtime_adjustment,
            stationtime_adjustment,
            augment_variable=True,
            qualifying_leg=qualifying_leg
        )