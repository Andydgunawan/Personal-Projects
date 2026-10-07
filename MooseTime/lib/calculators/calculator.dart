class Calculator {
  int zuluConstant;

  Calculator({
    this.zuluConstant = 0,
  });

  void setZuluConstant(int zuluConstant) {
    this.zuluConstant = zuluConstant;
  }

  DateTime calculateFourteenHrSet(DateTime zuluAlertTime) {
    return zuluAlertTime.subtract(
      const Duration(hours: 14),
    );
  }

  DateTime calculateLastAmbien(DateTime zuluAlertTime) {
    return zuluAlertTime.subtract(
      const Duration(hours: 6),
    );
  }

  DateTime calculateToLocalTime(DateTime zuluTime) {
    return zuluTime.subtract(
      Duration(hours: zuluConstant),
    );
  }
}