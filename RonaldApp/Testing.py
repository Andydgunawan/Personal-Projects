from datetime import datetime, timedelta

from Calculator.FlightCalculator.AirlandBasic import AirlandBasic
from Calculator.FlightCalculator.AirlandAugmented import AirlandAugmented
from Calculator.FlightCalculator.AirdropBasic import AirdropBasic
from Calculator.FlightCalculator.AirdropAugmented import AirdropAugmented

from Calculator.AlertCalculator.Alpha import Alpha
from Calculator.AlertCalculator.Bravo import Bravo


def test_airland_basic():
    takeoff = datetime(2026, 9, 22, 12, 0)

    calc = AirlandBasic(takeoff)

    assert calc.calculate_last_drink() == datetime(2026, 9, 22, 0, 0)
    assert calc.calculate_zulu_alert_time() == datetime(2026, 9, 22, 8, 15)
    assert calc.calculate_zulu_show_time() == datetime(2026, 9, 22, 9, 15)
    assert calc.calculate_zulu_station_time() == datetime(2026, 9, 22, 11, 15)
    assert calc.calculate_zulu_training_event_time() == datetime(2026, 9, 23, 0, 0)
    assert calc.calculate_zulu_tar_time() == datetime(2026, 9, 22, 23, 15)
    assert calc.calculate_zulu_fdp_time() == datetime(2026, 9, 23, 1, 15)
    assert calc.calculate_zulu_ap_inopfdp_time() == datetime(2026, 9, 22, 21, 15)
    assert calc.calculate_zulu_cdt_time() == datetime(2026, 9, 23, 3, 15)

    print("Airland Basic: PASSED")


def test_airdrop_basic():
    takeoff = datetime(2026, 9, 22, 12, 0)

    calc = AirdropBasic(takeoff)

    assert calc.calculate_zulu_alert_time() == datetime(2026, 9, 22, 7, 45)
    assert calc.calculate_zulu_show_time() == datetime(2026, 9, 22, 8, 45)
    assert calc.calculate_zulu_station_time() == datetime(2026, 9, 22, 11, 15)

    assert calc.calculate_zulu_tar_time() == datetime(2026, 9, 22, 22, 45)
    assert calc.calculate_zulu_fdp_time() == datetime(2026, 9, 23, 0, 45)

    print("Airdrop Basic: PASSED")


def test_airland_augmented():
    takeoff = datetime(2026, 9, 22, 12, 0)

    calc = AirlandAugmented(
        takeoff,
        qualifying_leg=True
    )

    assert calc.calculate_zulu_alert_time() == datetime(2026, 9, 22, 8, 15)
    assert calc.calculate_zulu_show_time() == datetime(2026, 9, 22, 9, 15)

    # qualifying leg
    assert calc.calculate_zulu_tar_time() == datetime(2026, 9, 23, 3, 15)
    assert calc.calculate_zulu_fdp_time() == datetime(2026, 9, 23, 9, 15)

    print("Airland Augmented qualifying leg: PASSED")


def test_airland_augmented_no_qualifying_leg():
    takeoff = datetime(2026, 9, 22, 12, 0)

    calc = AirlandAugmented(
        takeoff,
        qualifying_leg=False
    )

    calc.calculate_zulu_alert_time()
    calc.calculate_zulu_show_time()

    assert calc.calculate_zulu_tar_time() == datetime(2026, 9, 22, 23, 15)
    assert calc.calculate_zulu_fdp_time() == datetime(2026, 9, 23, 1, 15)

    print("Airland Augmented non-qualifying leg: PASSED")


def test_airdrop_augmented():
    takeoff = datetime(2026, 9, 22, 12, 0)

    calc = AirdropAugmented(
        takeoff,
        qualifying_leg=True
    )

    assert calc.calculate_zulu_alert_time() == datetime(2026, 9, 22, 7, 45)
    assert calc.calculate_zulu_show_time() == datetime(2026, 9, 22, 8, 45)

    assert calc.calculate_zulu_tar_time() == datetime(2026, 9, 23, 2, 45)
    assert calc.calculate_zulu_fdp_time() == datetime(2026, 9, 23, 8, 45)

    print("Airdrop Augmented qualifying leg: PASSED")


def test_airdrop_augmented_no_qualifying_leg():
    takeoff = datetime(2026, 9, 22, 12, 0)

    calc = AirdropAugmented(
        takeoff,
        qualifying_leg=False
    )

    calc.calculate_zulu_alert_time()
    calc.calculate_zulu_show_time()

    assert calc.calculate_zulu_tar_time() == datetime(2026, 9, 22, 22, 45)
    assert calc.calculate_zulu_fdp_time() == datetime(2026, 9, 23, 0, 45)

    print("Airdrop Augmented non-qualifying leg: PASSED")


def test_alpha():
    alert = datetime(2026, 9, 23, 8, 0)

    calc = Alpha(alert)

    assert calc.burnout_constant == 48

    assert calc.calculate_last_drink() == datetime(2026, 9, 22, 20, 0)
    assert calc.calculate_burnout_time() == datetime(2026, 9, 25, 8, 0)
    assert calc.calculate_earliest_reset() == datetime(2026, 9, 25, 20, 0)

    print("Alpha: PASSED")


def test_bravo():
    alert = datetime(2026, 9, 23, 8, 0)

    calc = Bravo(
        alert,
        burnout_constant=72
    )

    assert calc.burnout_constant == 72

    assert calc.calculate_last_drink() == datetime(2026, 9, 22, 20, 0)
    assert calc.calculate_burnout_time() == datetime(2026, 9, 26, 8, 0)
    assert calc.calculate_earliest_reset() == datetime(2026, 9, 26, 20, 0)

    print("Bravo 72 hours: PASSED")


def test_bravo_slider_change():
    alert = datetime(2026, 9, 23, 8, 0)

    calc = Bravo(alert)

    assert calc.burnout_constant == 48

    calc.set_burnout_constant(96)

    assert calc.burnout_constant == 96
    assert calc.calculate_burnout_time() == datetime(2026, 9, 27, 8, 0)
    assert calc.calculate_earliest_reset() == datetime(2026, 9, 27, 20, 0)

    print("Bravo slider change: PASSED")


def test_bravo_invalid_values():
    alert = datetime(2026, 9, 23, 8, 0)

    try:
        Bravo(alert, burnout_constant=47)
        print("Bravo lower limit: FAILED")
    except ValueError:
        print("Bravo lower limit validation: PASSED")

    try:
        Bravo(alert, burnout_constant=169)
        print("Bravo upper limit: FAILED")
    except ValueError:
        print("Bravo upper limit validation: PASSED")


# Run all tests
test_airland_basic()
test_airdrop_basic()

test_airland_augmented()
test_airland_augmented_no_qualifying_leg()

test_airdrop_augmented()
test_airdrop_augmented_no_qualifying_leg()

test_alpha()

test_bravo()
test_bravo_slider_change()
test_bravo_invalid_values()

print("\nALL TESTS FINISHED")