from datetime import datetime

from Calculator.FlightCalculator.AirlandBasic import AirlandBasic
from Calculator.FlightCalculator.AirlandAugmented import AirlandAugmented
from Calculator.FlightCalculator.AirdropBasic import AirdropBasic
from Calculator.FlightCalculator.AirdropAugmented import AirdropAugmented
from Calculator.AlertCalculator.Alpha import Alpha
from Calculator.AlertCalculator.Bravo import Bravo

# Test takeoff time
takeoff = datetime(2026, 9, 22, 12, 0)

# Testing  Airland Basic
# Create an Airland Basic calculator
calc = AirlandBasic(takeoff)

# Run calculations
print("Last Drink:", calc.calculate_last_drink())
print("Alert:", calc.calculate_zulu_alert_time())
print("Show:", calc.calculate_zulu_show_time())
print("Station:", calc.calculate_zulu_station_time())
print("Training Event:", calc.calculate_zulu_training_event_time())
print("TAR:", calc.calculate_zulu_tar_time())
print("FDP:", calc.calculate_zulu_fdp_time())
print("AP Inop FDP:", calc.calculate_zulu_ap_inopfdp_time())
print("CDT:", calc.calculate_zulu_cdt_time())

# Example alert time
alert_time = datetime(2026, 9, 23, 8, 0)

# Create Bravo calculator
bravo = Bravo(
    alert_time,
    burnout_constant=72
)

print("Alert:", bravo.zulu_alert_time)
print("Burnout Constant:", bravo.burnout_constant)
print("Last Drink:", bravo.calculate_last_drink())
print("Burnout Time:", bravo.calculate_burnout_time())
print("Earliest Reset:", bravo.calculate_earliest_reset())