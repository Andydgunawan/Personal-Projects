#Calculator.py
#parent calculator class for all other calculators to inherit from
from datetime import datetime, timedelta

class Calculator: 
    def __init__(self, zulu_constant = 0):
        self.zulu_constant = zulu_constant

    def set_zulu_constant(self, zulu_constant: int):
        self.zulu_constant = zulu_constant

    def calculate_fourteen_hr_set(self):
        return self.zulu_alert_time - timedelta(hours=14)
    
    def calculate_last_ambien(self):
        return self.zulu_alert_time - timedelta(hours=6)

    def calculate_to_local_time(self, zulu_time):
        return zulu_time - timedelta(hours=self.zulu_constant)




