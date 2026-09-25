#Bravo.py
#Bravo alert calculator, child of alert calculator class
from .AlertCalc import AlertCalc

class Bravo(AlertCalc):

    def __init__(
        self,
        zulu_alert_time,
        zulu_constant=0,
        burnout_constant=48
    ):
        self._validate_burnout_constant(burnout_constant)

        super().__init__(
            zulu_alert_time,
            burnout_constant=burnout_constant,
            zulu_constant=zulu_constant
        )

    #checks whether the burnout constant is within the valid range
    def _validate_burnout_constant(self, burnout_constant: int):
        if burnout_constant < 48 or burnout_constant > 168:
            raise ValueError(
                "Burnout constant must be between 48 and 168 hours."
            )

    def set_burnout_constant(self, burnout_constant: int):
        self._validate_burnout_constant(burnout_constant)
        self.burnout_constant = burnout_constant