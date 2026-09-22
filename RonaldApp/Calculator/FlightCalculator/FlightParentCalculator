#FlightParentCalculator.py
#parent class for flight calculator, child of calculator class
from datetime import datetime,timedelta
from ..Calculator import Calculator

class FlightParentCalculator(Calculator):

    def __init__(
        self,
        zulu_takeoff_time,
        #default values for showtime and stationtime adjustments, augment variable, and qualifying leg
        showtime_adjustment=timedelta(minutes=60),
        stationtime_adjustment=timedelta(minutes=45),
        augment_variable=False,
        qualifying_leg=False
    ):
        super().__init__()

        #inputs
        self.zulu_takeoff_time = zulu_takeoff_time
        self.showtime_adjustment = showtime_adjustment
        self.stationtime_adjustment = stationtime_adjustment
        self.augment_variable = augment_variable
        self.qualifying_leg = qualifying_leg

        #variables to be calculated
        self.last_drink = None
        self.zulu_alert_time = None
        self.zulu_show_time = None
        self.zulu_station_time = None
        self.zulu_training_event_time = None
        self.zulu_tar_time = None
        self.zulu_fdp_time = None
        self.zulu_ap_inopfdp_time = None
        self.zulu_cdt_time = None

    #setters
    def set_zulu_takeoff_time(self, zulu_takeoff_time: datetime):
        self.zulu_takeoff_time = zulu_takeoff_time
    
    def set_qualifying_leg(self, qualifying_leg: bool):
        self.qualifying_leg = qualifying_leg
    
    def set_showtime_adjustment(self, adjustment: timedelta):
        self.showtime_adjustment = adjustment

    def set_stationtime_adjustment(self, adjustment: timedelta):
        self.stationtime_adjustment = adjustment

    #calculations
    def calculate_last_drink(self) -> datetime:
            self.last_drink = (
                self.zulu_takeoff_time - timedelta(hours=12)
            )
            return self.last_drink
    
    def calculate_zulu_alert_time(self) -> datetime:
        self.zulu_alert_time = (
            self.zulu_takeoff_time - self.alert_offset
        )
        return self.zulu_alert_time

    def calculate_zulu_show_time(self) -> datetime:
        self.zulu_show_time = (
            self.zulu_alert_time + self.showtime_adjustment
        )
        return self.zulu_show_time  

    def calculate_zulu_station_time(self) -> datetime:
        self.zulu_station_time = (
            self.zulu_takeoff_time - self.stationtime_adjustment
        )
        return self.zulu_station_time

    def calculate_zulu_training_event_time(self) -> datetime:
        self.zulu_training_event_time = (
            self.zulu_takeoff_time + timedelta(hours=12)
        )
        return self.zulu_training_event_time

    def calculate_zulu_tar_time(self) -> datetime:
        # if augment_variable: then true -> use qualifying leg adjustment, else use standard adjustment
        if self.augment_variable: 
            if self.qualifying_leg:
                #if qualifying leg -> true, then use 18 hour adjustment, else use 14 hour adjustment 
                self.zulu_tar_time = self.zulu_show_time + timedelta(hours=18)
            else:
                self.zulu_tar_time = self.zulu_show_time + timedelta(hours=14)
            return self.zulu_tar_time
        else:
            self.zulu_tar_time = self.zulu_show_time + timedelta(hours=14)
            return self.zulu_tar_time
        

    def calculate_zulu_fdp_time(self) -> datetime:
        #if augment_variable: then true -> use qualifying leg adjustment, else use standard adjustment
        if self.augment_variable:
            if self.qualifying_leg:
                #if qualifying leg -> true, then use 24 hour adjustment, else use 16 hour adjustment  
                self.zulu_fdp_time = self.zulu_show_time + timedelta(hours=24)
            else:
                self.zulu_fdp_time = self.zulu_show_time + timedelta(hours=16)
        else:
            self.zulu_fdp_time = self.zulu_show_time + timedelta(hours=16)
        return self.zulu_fdp_time

    def calculate_zulu_ap_inopfdp_time(self) -> datetime:
        self.zulu_ap_inopfdp_time = (
            self.zulu_show_time + timedelta(hours=12)
        )
        return self.zulu_ap_inopfdp_time

    def calculate_zulu_cdt_time(self) -> datetime:
        self.zulu_cdt_time = (
            self.zulu_show_time + timedelta(hours=18)
        )
        return self.zulu_cdt_time