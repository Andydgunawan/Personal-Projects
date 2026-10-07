#AirdropAugmented.py
#parent class for airdrop augmented calculator, child of flight parent calc class
from datetime import timedelta
from .FlightParentCalculator import FlightParentCalculator

class AirdropAugmented(FlightParentCalculator):
    alert_offset = timedelta(hours=4, minutes=15)
    def __init__(self, 
                 zulu_takeoff_time, 
                showtime_adjustment=timedelta(minutes=60),
                stationtime_adjustment=timedelta(minutes=45),
                zulu_constant=0,
                qualifying_leg=False):

        super().__init__(
            zulu_takeoff_time,
            showtime_adjustment,
            stationtime_adjustment,
            augment_variable=True,
            zulu_constant=zulu_constant,
            qualifying_leg=qualifying_leg
        )
    
