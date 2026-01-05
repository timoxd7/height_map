/// Global configuration for the application
/// This class contains flags and settings that control app-wide behavior
class GlobalConfig {
  GlobalConfig._();

  /// Whether to log verbose barometer readings (each reading)
  /// Set to true only when debugging barometer-specific issues
  static bool logBarometerReadings = false;

  /// Whether to log verbose GPS readings (each reading)
  /// Set to true only when debugging GPS-specific issues
  static bool logGpsReadings = false;

  /// Whether to log verbose location stream updates
  /// Set to true only when debugging location tracking issues
  static bool logLocationUpdates = false;

  /// Whether to log API requests and responses in detail
  /// Set to true when debugging API issues
  static bool logApiDetails = true;

  /// Whether to log BLoC state changes
  /// Set to true when debugging state management issues
  static bool logBlocEvents = true;
}
