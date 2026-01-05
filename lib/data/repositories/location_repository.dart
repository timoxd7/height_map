import '../../core/utils/result.dart';
import '../datasources/datasources.dart';
import '../models/models.dart';

/// Repository for managing location data
class LocationRepository {
  final LocationDataSource _locationDataSource;

  LocationRepository({required LocationDataSource locationDataSource})
    : _locationDataSource = locationDataSource;

  /// Stream of position updates
  Stream<Position> get positionStream => _locationDataSource.positionStream;

  /// Get current position
  FutureResult<Position> getCurrentPosition() {
    return _locationDataSource.getCurrentPosition();
  }

  /// Start location tracking
  FutureResult<void> startTracking({Duration? interval}) {
    return _locationDataSource.startListening(
      interval: interval ?? const Duration(seconds: 5),
    );
  }

  /// Stop location tracking
  void stopTracking() {
    _locationDataSource.stopListening();
  }

  /// Check if location services are available
  Future<bool> isLocationAvailable() {
    return _locationDataSource.isAvailable();
  }

  /// Open location settings
  Future<bool> openLocationSettings() {
    return _locationDataSource.openLocationSettings();
  }

  /// Open app settings
  Future<bool> openAppSettings() {
    return _locationDataSource.openAppSettings();
  }

  /// Dispose resources
  void dispose() {
    _locationDataSource.dispose();
  }
}
