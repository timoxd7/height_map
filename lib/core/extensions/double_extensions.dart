/// Extension methods for double values
extension DoubleExtensions on double {
  /// Format as meters with unit
  String toMetersString({int decimals = 1}) {
    return '${toStringAsFixed(decimals)} m';
  }

  /// Format as feet with unit
  String toFeetString({int decimals = 1}) {
    final feet = this * 3.28084;
    return '${feet.toStringAsFixed(decimals)} ft';
  }

  /// Format as meters with sign (for differences)
  String toDifferenceString({int decimals = 1}) {
    final sign = this >= 0 ? '+' : '';
    return '$sign${toStringAsFixed(decimals)} m';
  }

  /// Convert meters to feet
  double toFeet() => this * 3.28084;

  /// Convert feet to meters
  double toMeters() => this / 3.28084;

  /// Calculate barometric altitude from pressure
  /// Uses the barometric formula: h = 44330 * (1 - (P/P0)^(1/5.255))
  /// where P is the measured pressure and P0 is sea level pressure (1013.25 hPa)
  static double fromPressure(
    double pressureHPa, {
    double seaLevelPressure = 1013.25,
  }) {
    return 44330.0 * (1.0 - (pressureHPa / seaLevelPressure).pow(1.0 / 5.255));
  }
}

extension NumPow on num {
  /// Power function for num
  double pow(num exponent) {
    return toDouble().pow(exponent);
  }
}

extension DoublePow on double {
  /// Power function for double
  double pow(num exponent) {
    return double.parse((this).toString()).toDouble().power(exponent);
  }

  double power(num exponent) {
    if (exponent == 0) return 1;
    if (exponent == 1) return this;
    if (exponent is int && exponent > 0) {
      double result = 1;
      for (int i = 0; i < exponent; i++) {
        result *= this;
      }
      return result;
    }
    // For non-integer exponents, use dart:math
    return _mathPow(this, exponent.toDouble());
  }
}

double _mathPow(double base, double exponent) {
  // Implementation using natural log approximation for non-integer powers
  if (base <= 0) return 0;
  return _exp(exponent * _ln(base));
}

double _ln(double x) {
  if (x <= 0) return double.negativeInfinity;
  // Using Taylor series approximation
  double result = 0;
  double y = (x - 1) / (x + 1);
  double y2 = y * y;
  double term = y;
  for (int i = 1; i <= 100; i += 2) {
    result += term / i;
    term *= y2;
  }
  return 2 * result;
}

double _exp(double x) {
  // Using Taylor series approximation
  double result = 1;
  double term = 1;
  for (int i = 1; i <= 100; i++) {
    term *= x / i;
    result += term;
    if (term.abs() < 1e-15) break;
  }
  return result;
}
