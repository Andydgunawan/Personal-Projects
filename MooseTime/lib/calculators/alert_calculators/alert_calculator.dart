import '../calculator.dart';

class AlertCalculator extends Calculator {
  DateTime zuluAlertTime;
  int burnoutConstant;

  DateTime? lastDrink;
  DateTime? burnoutTime;
  DateTime? earliestReset;

  DateTime? localAlertTime;
  DateTime? localLastDrink;
  DateTime? localBurnoutTime;
  DateTime? localEarliestReset;

  AlertCalculator({
    required this.zuluAlertTime,
    this.burnoutConstant = 48,
    super.zuluConstant,
  });

  DateTime calculateLastDrink() {
    lastDrink = zuluAlertTime.subtract(
      const Duration(hours: 12),
    );

    return lastDrink!;
  }

  DateTime calculateBurnoutTime() {
    burnoutTime = zuluAlertTime.add(
      Duration(hours: burnoutConstant),
    );

    return burnoutTime!;
  }

  DateTime calculateEarliestReset() {
    earliestReset = calculateBurnoutTime().add(
      const Duration(hours: 12),
    );

    return earliestReset!;
  }

  void calculateLocalTimes() {
    localAlertTime = calculateToLocalTime(
      zuluAlertTime,
    );

    localLastDrink = calculateToLocalTime(
      lastDrink!,
    );

    localBurnoutTime = calculateToLocalTime(
      burnoutTime!,
    );

    localEarliestReset = calculateToLocalTime(
      earliestReset!,
    );
  }
}