import 'package:flutter_test/flutter_test.dart';

import 'package:moose_time/calculators/flight_calculators/airland_basic.dart';
import 'package:moose_time/calculators/flight_calculators/airland_augmented.dart';
import 'package:moose_time/calculators/flight_calculators/airdrop_basic.dart';
import 'package:moose_time/calculators/flight_calculators/airdrop_augmented.dart';

import 'package:moose_time/calculators/alert_calculators/alpha.dart';
import 'package:moose_time/calculators/alert_calculators/bravo.dart';

void main() {
  test('Airland Basic Local', () {
    final calc = AirlandBasic(
      zuluTakeoffTime: DateTime(2026, 9, 22, 12, 0),
      zuluConstant: 4,
    );

    calc.calculateLastDrink();
    calc.calculateZuluAlertTime();
    calc.calculateZuluShowTime();
    calc.calculateZuluStationTime();
    calc.calculateZuluTrainingEventTime();
    calc.calculateZuluTarTime();
    calc.calculateZuluFdpTime();
    calc.calculateZuluApInopFdpTime();
    calc.calculateZuluCdtTime();

    calc.calculateLocalTimes();

    expect(
      calc.localLastDrink,
      DateTime(2026, 9, 21, 20, 0),
    );

    expect(
      calc.localAlertTime,
      DateTime(2026, 9, 22, 4, 15),
    );

    expect(
      calc.localShowTime,
      DateTime(2026, 9, 22, 5, 15),
    );

    expect(
      calc.localStationTime,
      DateTime(2026, 9, 22, 7, 15),
    );

    expect(
      calc.localTrainingEventTime,
      DateTime(2026, 9, 22, 20, 0),
    );

    expect(
      calc.localTarTime,
      DateTime(2026, 9, 22, 19, 15),
    );

    expect(
      calc.localFdpTime,
      DateTime(2026, 9, 22, 21, 15),
    );

    expect(
      calc.localApInopFdpTime,
      DateTime(2026, 9, 22, 17, 15),
    );

    expect(
      calc.localCdtTime,
      DateTime(2026, 9, 22, 23, 15),
    );
  });

  test('Airdrop Basic Local', () {
    final calc = AirdropBasic(
      zuluTakeoffTime: DateTime(2026, 9, 22, 12, 0),
      zuluConstant: 4,
    );

    calc.calculateLastDrink();
    calc.calculateZuluAlertTime();
    calc.calculateZuluShowTime();
    calc.calculateZuluStationTime();
    calc.calculateZuluTrainingEventTime();
    calc.calculateZuluTarTime();
    calc.calculateZuluFdpTime();
    calc.calculateZuluApInopFdpTime();
    calc.calculateZuluCdtTime();

    calc.calculateLocalTimes();

    expect(
      calc.localAlertTime,
      DateTime(2026, 9, 22, 3, 45),
    );

    expect(
      calc.localShowTime,
      DateTime(2026, 9, 22, 4, 45),
    );

    expect(
      calc.localTarTime,
      DateTime(2026, 9, 22, 18, 45),
    );

    expect(
      calc.localFdpTime,
      DateTime(2026, 9, 22, 20, 45),
    );
  });

  test('Airland Augmented Qualifying Local', () {
    final calc = AirlandAugmented(
      zuluTakeoffTime: DateTime(2026, 9, 22, 12, 0),
      zuluConstant: 4,
      qualifyingLeg: true,
    );

    calc.calculateLastDrink();
    calc.calculateZuluAlertTime();
    calc.calculateZuluShowTime();
    calc.calculateZuluStationTime();
    calc.calculateZuluTrainingEventTime();
    calc.calculateZuluTarTime();
    calc.calculateZuluFdpTime();
    calc.calculateZuluApInopFdpTime();
    calc.calculateZuluCdtTime();

    calc.calculateLocalTimes();

    expect(
      calc.localAlertTime,
      DateTime(2026, 9, 22, 4, 15),
    );

    expect(
      calc.localShowTime,
      DateTime(2026, 9, 22, 5, 15),
    );

    expect(
      calc.localTarTime,
      DateTime(2026, 9, 22, 23, 15),
    );

    expect(
      calc.localFdpTime,
      DateTime(2026, 9, 23, 5, 15),
    );
  });

  test('Airdrop Augmented Qualifying Local', () {
    final calc = AirdropAugmented(
      zuluTakeoffTime: DateTime(2026, 9, 22, 12, 0),
      zuluConstant: 4,
      qualifyingLeg: true,
    );

    calc.calculateLastDrink();
    calc.calculateZuluAlertTime();
    calc.calculateZuluShowTime();
    calc.calculateZuluStationTime();
    calc.calculateZuluTrainingEventTime();
    calc.calculateZuluTarTime();
    calc.calculateZuluFdpTime();
    calc.calculateZuluApInopFdpTime();
    calc.calculateZuluCdtTime();

    calc.calculateLocalTimes();

    expect(
      calc.localAlertTime,
      DateTime(2026, 9, 22, 3, 45),
    );

    expect(
      calc.localShowTime,
      DateTime(2026, 9, 22, 4, 45),
    );

    expect(
      calc.localTarTime,
      DateTime(2026, 9, 22, 22, 45),
    );

    expect(
      calc.localFdpTime,
      DateTime(2026, 9, 23, 4, 45),
    );
  });

  test('Alpha Local', () {
    final alpha = Alpha(
      zuluAlertTime: DateTime(2026, 9, 23, 8, 0),
      zuluConstant: 4,
    );

    alpha.calculateLastDrink();
    alpha.calculateBurnoutTime();
    alpha.calculateEarliestReset();
    alpha.calculateLocalTimes();

    expect(
      alpha.localAlertTime,
      DateTime(2026, 9, 23, 4, 0),
    );

    expect(
      alpha.localLastDrink,
      DateTime(2026, 9, 22, 16, 0),
    );

    expect(
      alpha.localBurnoutTime,
      DateTime(2026, 9, 25, 4, 0),
    );

    expect(
      alpha.localEarliestReset,
      DateTime(2026, 9, 25, 16, 0),
    );
  });

  test('Bravo Local', () {
    final bravo = Bravo(
      zuluAlertTime: DateTime(2026, 9, 23, 8, 0),
      zuluConstant: 4,
      burnoutConstant: 72,
    );

    bravo.calculateLastDrink();
    bravo.calculateBurnoutTime();
    bravo.calculateEarliestReset();
    bravo.calculateLocalTimes();

    expect(
      bravo.localAlertTime,
      DateTime(2026, 9, 23, 4, 0),
    );

    expect(
      bravo.localLastDrink,
      DateTime(2026, 9, 22, 16, 0),
    );

    expect(
      bravo.localBurnoutTime,
      DateTime(2026, 9, 26, 4, 0),
    );

    expect(
      bravo.localEarliestReset,
      DateTime(2026, 9, 26, 16, 0),
    );
  });
}