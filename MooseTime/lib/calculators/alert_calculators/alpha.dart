import 'alert_calculator.dart';

class Alpha extends AlertCalculator {
  Alpha({
    required super.zuluAlertTime,
    super.zuluConstant,
  }) : super(
          burnoutConstant: 48,
        );
}