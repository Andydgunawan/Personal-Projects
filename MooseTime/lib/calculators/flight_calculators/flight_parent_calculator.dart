import '../calculator.dart';

class FlightParentCalculator extends Calculator {
  DateTime zuluTakeoffTime;

  Duration showtimeAdjustment;
  Duration stationtimeAdjustment;

  bool augmentVariable;
  bool qualifyingLeg;

  Duration alertOffset;

  DateTime? lastDrink;
  DateTime? zuluAlertTime;
  DateTime? zuluShowTime;
  DateTime? zuluStationTime;
  DateTime? zuluTrainingEventTime;
  DateTime? zuluTarTime;
  DateTime? zuluFdpTime;
  DateTime? zuluApInopFdpTime;
  DateTime? zuluCdtTime;

  DateTime? localLastDrink;
  DateTime? localAlertTime;
  DateTime? localShowTime;
  DateTime? localStationTime;
  DateTime? localTrainingEventTime;
  DateTime? localTarTime;
  DateTime? localFdpTime;
  DateTime? localApInopFdpTime;
  DateTime? localCdtTime;

  FlightParentCalculator({
    required this.zuluTakeoffTime,
    required this.alertOffset,
    this.showtimeAdjustment = const Duration(minutes: 60),
    this.stationtimeAdjustment = const Duration(minutes: 45),
    super.zuluConstant,
    this.augmentVariable = false,
    this.qualifyingLeg = false,
  });

  void setZuluTakeoffTime(DateTime zuluTakeoffTime) {
    this.zuluTakeoffTime = zuluTakeoffTime;
  }

  void setQualifyingLeg(bool qualifyingLeg) {
    this.qualifyingLeg = qualifyingLeg;
  }

  void setShowtimeAdjustment(Duration adjustment) {
    showtimeAdjustment = adjustment;
  }

  void setStationtimeAdjustment(Duration adjustment) {
    stationtimeAdjustment = adjustment;
  }

  DateTime calculateLastDrink() {
    lastDrink = zuluTakeoffTime.subtract(
      const Duration(hours: 12),
    );

    return lastDrink!;
  }

  DateTime calculateZuluAlertTime() {
    zuluAlertTime = zuluTakeoffTime.subtract(
      alertOffset,
    );

    return zuluAlertTime!;
  }

  DateTime calculateZuluShowTime() {
    zuluShowTime = zuluAlertTime!.add(
      showtimeAdjustment,
    );

    return zuluShowTime!;
  }

  DateTime calculateZuluStationTime() {
    zuluStationTime = zuluTakeoffTime.subtract(
      stationtimeAdjustment,
    );

    return zuluStationTime!;
  }

  DateTime calculateZuluTrainingEventTime() {
    zuluTrainingEventTime = zuluTakeoffTime.add(
      const Duration(hours: 12),
    );

    return zuluTrainingEventTime!;
  }

  DateTime calculateZuluTarTime() {
    if (augmentVariable && qualifyingLeg) {
      zuluTarTime = zuluShowTime!.add(
        const Duration(hours: 18),
      );
    } else {
      zuluTarTime = zuluShowTime!.add(
        const Duration(hours: 14),
      );
    }

    return zuluTarTime!;
  }

  DateTime calculateZuluFdpTime() {
    if (augmentVariable && qualifyingLeg) {
      zuluFdpTime = zuluShowTime!.add(
        const Duration(hours: 24),
      );
    } else {
      zuluFdpTime = zuluShowTime!.add(
        const Duration(hours: 16),
      );
    }

    return zuluFdpTime!;
  }

  DateTime calculateZuluApInopFdpTime() {
    zuluApInopFdpTime = zuluShowTime!.add(
      const Duration(hours: 12),
    );

    return zuluApInopFdpTime!;
  }

  DateTime calculateZuluCdtTime() {
    zuluCdtTime = zuluShowTime!.add(
      const Duration(hours: 18),
    );

    return zuluCdtTime!;
  }

  void calculateLocalTimes() {
    localLastDrink = calculateToLocalTime(lastDrink!);
    localAlertTime = calculateToLocalTime(zuluAlertTime!);
    localShowTime = calculateToLocalTime(zuluShowTime!);
    localStationTime = calculateToLocalTime(zuluStationTime!);
    localTrainingEventTime =
        calculateToLocalTime(zuluTrainingEventTime!);
    localTarTime = calculateToLocalTime(zuluTarTime!);
    localFdpTime = calculateToLocalTime(zuluFdpTime!);
    localApInopFdpTime =
        calculateToLocalTime(zuluApInopFdpTime!);
    localCdtTime = calculateToLocalTime(zuluCdtTime!);
  }
}