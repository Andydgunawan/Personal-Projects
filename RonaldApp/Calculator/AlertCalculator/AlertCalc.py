#parent class for alert calculator, child of calculator class
from datetime import timedelta
from Calculator.Calculator import Calculator

class AlertCalc(Calculator):
    def __init__(self, zulu_alert_time, burnout_constant=48):
        super().__init__(zulu_alert_time)

        self.burnout_constant = burnout_constant

    def calculate_last_drink(self):
        return self.zulu_alert_time - timedelta(hours=12)

    def calculate_burnout_time(self):
        return self.zulu_alert_time + timedelta(
            hours=self.burnout_constant
        )

    def calculate_earliest_reset(self):
        return self.calculate_burnout_time() + timedelta(hours=12)
