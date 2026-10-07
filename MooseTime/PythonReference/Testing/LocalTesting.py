import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))

from datetime import datetime
from Calculator.FlightCalculator.AirlandBasic import AirlandBasic
from Calculator.FlightCalculator.AirlandAugmented import AirlandAugmented
from Calculator.FlightCalculator.AirdropBasic import AirdropBasic
from Calculator.FlightCalculator.AirdropAugmented import AirdropAugmented
from Calculator.AlertCalculator.Alpha import Alpha
from Calculator.AlertCalculator.Bravo import Bravo

def test_airland_basic_local():
    takeoff = datetime(2026, 9, 22, 12, 0)

    calc = AirlandBasic(
        takeoff,
        zulu_constant=4
    )

    calc.calculate_last_drink()
    calc.calculate_zulu_alert_time()
    calc.calculate_zulu_show_time()
    calc.calculate_zulu_station_time()
    calc.calculate_zulu_training_event_time()
    calc.calculate_zulu_tar_time()
    calc.calculate_zulu_fdp_time()
    calc.calculate_zulu_ap_inopfdp_time()
    calc.calculate_zulu_cdt_time()

    calc.calculate_local_times()

    assert calc.local_last_drink == datetime(2026, 9, 21, 20, 0)
    assert calc.local_alert_time == datetime(2026, 9, 22, 4, 15)
    assert calc.local_show_time == datetime(2026, 9, 22, 5, 15)
    assert calc.local_station_time == datetime(2026, 9, 22, 7, 15)
    assert calc.local_training_event_time == datetime(2026, 9, 22, 20, 0)
    assert calc.local_tar_time == datetime(2026, 9, 22, 19, 15)
    assert calc.local_fdp_time == datetime(2026, 9, 22, 21, 15)
    assert calc.local_ap_inopfdp_time == datetime(2026, 9, 22, 17, 15)
    assert calc.local_cdt_time == datetime(2026, 9, 22, 23, 15)

    print("Airland Basic Local: PASSED")


def test_airdrop_basic_local():
    takeoff = datetime(2026, 9, 22, 12, 0)

    calc = AirdropBasic(
        takeoff,
        zulu_constant=4
    )

    calc.calculate_last_drink()
    calc.calculate_zulu_alert_time()
    calc.calculate_zulu_show_time()
    calc.calculate_zulu_station_time()
    calc.calculate_zulu_training_event_time()
    calc.calculate_zulu_tar_time()
    calc.calculate_zulu_fdp_time()
    calc.calculate_zulu_ap_inopfdp_time()
    calc.calculate_zulu_cdt_time()

    calc.calculate_local_times()

    assert calc.local_last_drink == datetime(2026, 9, 21, 20, 0)
    assert calc.local_alert_time == datetime(2026, 9, 22, 3, 45)
    assert calc.local_show_time == datetime(2026, 9, 22, 4, 45)
    assert calc.local_station_time == datetime(2026, 9, 22, 7, 15)
    assert calc.local_training_event_time == datetime(2026, 9, 22, 20, 0)
    assert calc.local_tar_time == datetime(2026, 9, 22, 18, 45)
    assert calc.local_fdp_time == datetime(2026, 9, 22, 20, 45)
    assert calc.local_ap_inopfdp_time == datetime(2026, 9, 22, 16, 45)
    assert calc.local_cdt_time == datetime(2026, 9, 22, 22, 45)

    print("Airdrop Basic Local: PASSED")


def test_airland_augmented_local():
    takeoff = datetime(2026, 9, 22, 12, 0)

    calc = AirlandAugmented(
        takeoff,
        zulu_constant=4,
        qualifying_leg=True
    )

    calc.calculate_last_drink()
    calc.calculate_zulu_alert_time()
    calc.calculate_zulu_show_time()
    calc.calculate_zulu_station_time()
    calc.calculate_zulu_training_event_time()
    calc.calculate_zulu_tar_time()
    calc.calculate_zulu_fdp_time()
    calc.calculate_zulu_ap_inopfdp_time()
    calc.calculate_zulu_cdt_time()

    calc.calculate_local_times()

    assert calc.local_alert_time == datetime(2026, 9, 22, 4, 15)
    assert calc.local_show_time == datetime(2026, 9, 22, 5, 15)
    assert calc.local_tar_time == datetime(2026, 9, 22, 23, 15)
    assert calc.local_fdp_time == datetime(2026, 9, 23, 5, 15)

    print("Airland Augmented Local: PASSED")


def test_airland_augmented_no_qualifying_leg_local():
    takeoff = datetime(2026, 9, 22, 12, 0)

    calc = AirlandAugmented(
        takeoff,
        zulu_constant=4,
        qualifying_leg=False
    )

    calc.calculate_last_drink()
    calc.calculate_zulu_alert_time()
    calc.calculate_zulu_show_time()
    calc.calculate_zulu_station_time()
    calc.calculate_zulu_training_event_time()
    calc.calculate_zulu_tar_time()
    calc.calculate_zulu_fdp_time()
    calc.calculate_zulu_ap_inopfdp_time()
    calc.calculate_zulu_cdt_time()

    calc.calculate_local_times()

    assert calc.local_tar_time == datetime(2026, 9, 22, 19, 15)
    assert calc.local_fdp_time == datetime(2026, 9, 22, 21, 15)

    print("Airland Augmented Non-Qualifying Local: PASSED")


def test_airdrop_augmented_local():
    takeoff = datetime(2026, 9, 22, 12, 0)

    calc = AirdropAugmented(
        takeoff,
        zulu_constant=4,
        qualifying_leg=True
    )

    calc.calculate_last_drink()
    calc.calculate_zulu_alert_time()
    calc.calculate_zulu_show_time()
    calc.calculate_zulu_station_time()
    calc.calculate_zulu_training_event_time()
    calc.calculate_zulu_tar_time()
    calc.calculate_zulu_fdp_time()
    calc.calculate_zulu_ap_inopfdp_time()
    calc.calculate_zulu_cdt_time()

    calc.calculate_local_times()

    assert calc.local_alert_time == datetime(2026, 9, 22, 3, 45)
    assert calc.local_show_time == datetime(2026, 9, 22, 4, 45)
    assert calc.local_tar_time == datetime(2026, 9, 22, 22, 45)
    assert calc.local_fdp_time == datetime(2026, 9, 23, 4, 45)

    print("Airdrop Augmented Local: PASSED")


def test_airdrop_augmented_no_qualifying_leg_local():
    takeoff = datetime(2026, 9, 22, 12, 0)

    calc = AirdropAugmented(
        takeoff,
        zulu_constant=4,
        qualifying_leg=False
    )

    calc.calculate_last_drink()
    calc.calculate_zulu_alert_time()
    calc.calculate_zulu_show_time()
    calc.calculate_zulu_station_time()
    calc.calculate_zulu_training_event_time()
    calc.calculate_zulu_tar_time()
    calc.calculate_zulu_fdp_time()
    calc.calculate_zulu_ap_inopfdp_time()
    calc.calculate_zulu_cdt_time()

    calc.calculate_local_times()

    assert calc.local_tar_time == datetime(2026, 9, 22, 18, 45)
    assert calc.local_fdp_time == datetime(2026, 9, 22, 20, 45)

    print("Airdrop Augmented Non-Qualifying Local: PASSED")


def test_alpha_local():
    alert = datetime(2026, 9, 23, 8, 0)

    calc = Alpha(
        alert,
        zulu_constant=4
    )

    calc.calculate_last_drink()
    calc.calculate_burnout_time()
    calc.calculate_earliest_reset()

    calc.calculate_local_times()

    assert calc.local_alert_time == datetime(2026, 9, 23, 4, 0)
    assert calc.local_last_drink == datetime(2026, 9, 22, 16, 0)
    assert calc.local_burnout_time == datetime(2026, 9, 25, 4, 0)
    assert calc.local_earliest_reset == datetime(2026, 9, 25, 16, 0)

    print("Alpha Local: PASSED")


def test_bravo_local():
    alert = datetime(2026, 9, 23, 8, 0)

    calc = Bravo(
        alert,
        burnout_constant=72,
        zulu_constant=4
    )

    calc.calculate_last_drink()
    calc.calculate_burnout_time()
    calc.calculate_earliest_reset()

    calc.calculate_local_times()

    assert calc.local_alert_time == datetime(2026, 9, 23, 4, 0)
    assert calc.local_last_drink == datetime(2026, 9, 22, 16, 0)
    assert calc.local_burnout_time == datetime(2026, 9, 26, 4, 0)
    assert calc.local_earliest_reset == datetime(2026, 9, 26, 16, 0)

    print("Bravo Local: PASSED")


# Run local-time tests
test_airland_basic_local()
test_airdrop_basic_local()

test_airland_augmented_local()
test_airland_augmented_no_qualifying_leg_local()

test_airdrop_augmented_local()
test_airdrop_augmented_no_qualifying_leg_local()

test_alpha_local()
test_bravo_local()

print("\nALL LOCAL TIME TESTS PASSED")