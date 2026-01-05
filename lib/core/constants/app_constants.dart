/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Height Map';
  static const String appVersion = '1.0.0';

  // Map Configuration
  static const double defaultZoom = 13.0;
  static const double minZoom = 3.0;
  static const double maxZoom = 18.0;

  // Sensor Configuration
  static const Duration sensorUpdateInterval = Duration(milliseconds: 500);
  static const Duration locationUpdateInterval = Duration(seconds: 5);

  // API Configuration
  static const String openTopoDataBaseUrl = 'https://api.opentopodata.org';
  static const String elevationDataset = 'srtm90m'; // SRTM 90m resolution

  // Barometer Constants
  static const double seaLevelPressure = 1013.25; // hPa (standard atmosphere)

  // UI Constants
  static const double borderRadius = 16.0;
  static const double smallBorderRadius = 8.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}
