#parent class for alert calculator, child of calculator class
from datetime import timedelta
import datetime
from ..Calculator import Calculator

class AlertCalc(Calculator):
    def __init__(self, 
                zulu_alert_time, 
                burnout_constant=48,
                zulu_constant=0
                ):
        super().__init__(zulu_alert_time, zulu_constant)

        # inputs
        self.zulu_alert_time = zulu_alert_time
        self.burnout_constant = burnout_constant

        # calculated values
        self.last_drink = None
        self.burnout_time = None
        self.earliest_reset = None

        self.burnout_constant = burnout_constant

    def calculate_last_drink(self):
        self.last_drink = (
        self.zulu_alert_time - timedelta(hours=12)
        )
        return self.last_drink

    def calculate_burnout_time(self)-> datetime:
        self.burnout_time = self.zulu_alert_time + timedelta(
            hours=self.burnout_constant
        ) 
        return self.burnout_time

    def calculate_earliest_reset(self) -> datetime:
        self.earliest_reset = (
            self.calculate_burnout_time()
            + timedelta(hours=12)
        )
        return self.earliest_reset
    
    def calculate_local_times(self):
        self.local_alert_time = self.calculate_to_local_time(
            self.zulu_alert_time
        )

        self.local_last_drink = self.calculate_to_local_time(
            self.last_drink
        )

        self.local_burnout_time = self.calculate_to_local_time(
            self.burnout_time
        )

        self.local_earliest_reset = self.calculate_to_local_time(
            self.earliest_reset
        )
