import 'alert_calculator.dart';

class Bravo extends AlertCalculator {
  Bravo({
    required super.zuluAlertTime,
    super.zuluConstant,
    int burnoutConstant = 48,
  }) : super(
          burnoutConstant: burnoutConstant,
        ) {
    validateBurnoutConstant(burnoutConstant);
  }

  void validateBurnoutConstant(int burnoutConstant) {
    if (burnoutConstant < 48 || burnoutConstant > 168) {
      throw ArgumentError(
        'Burnout constant must be between 48 and 168 hours.',
      );
    }
  }

  void setBurnoutConstant(int burnoutConstant) {
    validateBurnoutConstant(burnoutConstant);
    this.burnoutConstant = burnoutConstant;
  }
}