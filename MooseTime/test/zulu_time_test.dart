import 'package:flutter_test/flutter_test.dart';

import 'package:moose_time/calculators/flight_calculators/airland_basic.dart';
import 'package:moose_time/calculators/flight_calculators/airland_augmented.dart';
import 'package:moose_time/calculators/flight_calculators/airdrop_basic.dart';
import 'package:moose_time/calculators/flight_calculators/airdrop_augmented.dart';

import 'package:moose_time/calculators/alert_calculators/alpha.dart';
import 'package:moose_time/calculators/alert_calculators/bravo.dart';

void main() {
  test('Airland Basic Zulu', () {
    final calc = AirlandBasic(
      zuluTakeoffTime: DateTime(2026, 9, 22, 12, 0),
    );

    expect(
      calc.calculateLastDrink(),
      DateTime(2026, 9, 22, 0, 0),
    );

    expect(
      calc.calculateZuluAlertTime(),
      DateTime(2026, 9, 22, 8, 15),
    );

    expect(
      calc.calculateZuluShowTime(),
      DateTime(2026, 9, 22, 9, 15),
    );

    expect(
      calc.calculateZuluStationTime(),
      DateTime(2026, 9, 22, 11, 15),
    );

    expect(
      calc.calculateZuluTrainingEventTime(),
      DateTime(2026, 9, 23, 0, 0),
    );

    expect(
      calc.calculateZuluTarTime(),
      DateTime(2026, 9, 22, 23, 15),
    );

    expect(
      calc.calculateZuluFdpTime(),
      DateTime(2026, 9, 23, 1, 15),
    );

    expect(
      calc.calculateZuluApInopFdpTime(),
      DateTime(2026, 9, 22, 21, 15),
    );

    expect(
      calc.calculateZuluCdtTime(),
      DateTime(2026, 9, 23, 3, 15),
    );
  });

  test('Airdrop Basic Zulu', () {
    final calc = AirdropBasic(
      zuluTakeoffTime: DateTime(2026, 9, 22, 12, 0),
    );

    calc.calculateLastDrink();

    expect(
      calc.calculateZuluAlertTime(),
      DateTime(2026, 9, 22, 7, 45),
    );

    expect(
      calc.calculateZuluShowTime(),
      DateTime(2026, 9, 22, 8, 45),
    );

    expect(
      calc.calculateZuluStationTime(),
      DateTime(2026, 9, 22, 11, 15),
    );

    expect(
      calc.calculateZuluTarTime(),
      DateTime(2026, 9, 22, 22, 45),
    );

    expect(
      calc.calculateZuluFdpTime(),
      DateTime(2026, 9, 23, 0, 45),
    );
  });

  test('Airland Augmented Qualifying Zulu', () {
    final calc = AirlandAugmented(
      zuluTakeoffTime: DateTime(2026, 9, 22, 12, 0),
      qualifyingLeg: true,
    );

    calc.calculateZuluAlertTime();
    calc.calculateZuluShowTime();

    expect(
      calc.zuluAlertTime,
      DateTime(2026, 9, 22, 8, 15),
    );

    expect(
      calc.zuluShowTime,
      DateTime(2026, 9, 22, 9, 15),
    );

    expect(
      calc.calculateZuluTarTime(),
      DateTime(2026, 9, 23, 3, 15),
    );

    expect(
      calc.calculateZuluFdpTime(),
      DateTime(2026, 9, 23, 9, 15),
    );
  });

  test('Airland Augmented Non-Qualifying Zulu', () {
    final calc = AirlandAugmented(
      zuluTakeoffTime: DateTime(2026, 9, 22, 12, 0),
      qualifyingLeg: false,
    );

    calc.calculateZuluAlertTime();
    calc.calculateZuluShowTime();

    expect(
      calc.calculateZuluTarTime(),
      DateTime(2026, 9, 22, 23, 15),
    );

    expect(
      calc.calculateZuluFdpTime(),
      DateTime(2026, 9, 23, 1, 15),
    );
  });

  test('Airdrop Augmented Qualifying Zulu', () {
    final calc = AirdropAugmented(
      zuluTakeoffTime: DateTime(2026, 9, 22, 12, 0),
      qualifyingLeg: true,
    );

    calc.calculateZuluAlertTime();
    calc.calculateZuluShowTime();

    expect(
      calc.zuluAlertTime,
      DateTime(2026, 9, 22, 7, 45),
    );

    expect(
      calc.zuluShowTime,
      DateTime(2026, 9, 22, 8, 45),
    );

    expect(
      calc.calculateZuluTarTime(),
      DateTime(2026, 9, 23, 2, 45),
    );

    expect(
      calc.calculateZuluFdpTime(),
      DateTime(2026, 9, 23, 8, 45),
    );
  });

  test('Airdrop Augmented Non-Qualifying Zulu', () {
    final calc = AirdropAugmented(
      zuluTakeoffTime: DateTime(2026, 9, 22, 12, 0),
      qualifyingLeg: false,
    );

    calc.calculateZuluAlertTime();
    calc.calculateZuluShowTime();

    expect(
      calc.calculateZuluTarTime(),
      DateTime(2026, 9, 22, 22, 45),
    );

    expect(
      calc.calculateZuluFdpTime(),
      DateTime(2026, 9, 23, 0, 45),
    );
  });

  test('Alpha Zulu', () {
    final alpha = Alpha(
      zuluAlertTime: DateTime(2026, 9, 23, 8, 0),
    );

    expect(
      alpha.calculateLastDrink(),
      DateTime(2026, 9, 22, 20, 0),
    );

    expect(
      alpha.calculateBurnoutTime(),
      DateTime(2026, 9, 25, 8, 0),
    );

    expect(
      alpha.calculateEarliestReset(),
      DateTime(2026, 9, 25, 20, 0),
    );
  });

  test('Bravo 72 Hour Zulu', () {
    final bravo = Bravo(
      zuluAlertTime: DateTime(2026, 9, 23, 8, 0),
      burnoutConstant: 72,
    );

    expect(
      bravo.calculateLastDrink(),
      DateTime(2026, 9, 22, 20, 0),
    );

    expect(
      bravo.calculateBurnoutTime(),
      DateTime(2026, 9, 26, 8, 0),
    );

    expect(
      bravo.calculateEarliestReset(),
      DateTime(2026, 9, 26, 20, 0),
    );
  });
}