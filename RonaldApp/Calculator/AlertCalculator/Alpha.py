#Alpha alert calculator, child of alert calculator class
from .AlertCalc import AlertCalc

class Alpha(AlertCalc):
    def __init__(self, zulu_alert_time):
        super().__init__(
            zulu_alert_time,
            burnout_constant=48
        )