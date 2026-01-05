import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:dartz/dartz.dart';
import '../../core/config/global_config.dart';
import '../../core/utils/failure.dart';
import '../../core/utils/result.dart';
import '../models/models.dart';

/// Data source for GPS/location readings
class LocationDataSource {
  StreamSubscription<geo.Position>? _subscription;
  final _positionController = StreamController<Position>.broadcast();
  final _heightController = StreamController<HeightMeasurement>.broadcast();

  /// Stream of position updates
  Stream<Position> get positionStream => _positionController.stream;

  /// Stream of GPS height measurements
  Stream<HeightMeasurement> get heightStream => _heightController.stream;

  /// Get current position
  FutureResult<Position> getCurrentPosition() async {
    debugPrint('[LocationDS] Getting current position');
    try {
      final permission = await _checkPermission();
      if (permission.isLeft()) {
        debugPrint('[LocationDS] Permission check failed');
        return Left(permission.fold((l) => l, (r) => const UnknownFailure()));
      }

      debugPrint('[LocationDS] Permission OK, fetching position');
      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
        ),
      );

      debugPrint(
        '[LocationDS] Position: ${position.latitude}, ${position.longitude}, alt: ${position.altitude}m',
      );
      return Right(
        Position(
          latitude: position.latitude,
          longitude: position.longitude,
          altitude: position.altitude,
        ),
      );
    } catch (e) {
      debugPrint('[LocationDS] Error getting position: $e');
      return Left(LocationFailure(message: 'Failed to get position: $e'));
    }
  }

  /// Get current GPS altitude
  FutureResult<HeightMeasurement> getCurrentAltitude() async {
    try {
      final permission = await _checkPermission();
      if (permission.isLeft()) {
        return Left(permission.fold((l) => l, (r) => const UnknownFailure()));
      }

      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
        ),
      );

      return Right(
        HeightMeasurement(
          heightMeters: position.altitude,
          source: HeightSource.gps,
          accuracy: position.altitudeAccuracy,
          timestamp: DateTime.now(),
          isReliable:
              position.altitudeAccuracy < 50, // Reliable if accuracy < 50m
        ),
      );
    } catch (e) {
      return Left(LocationFailure(message: 'Failed to get GPS altitude: $e'));
    }
  }

  /// Start listening to location updates
  FutureResult<void> startListening({
    Duration interval = const Duration(seconds: 5),
  }) async {
    debugPrint('[LocationDS] Starting location listening');
    try {
      final permission = await _checkPermission();
      if (permission.isLeft()) {
        debugPrint('[LocationDS] Permission check failed for startListening');
        return permission;
      }

      debugPrint('[LocationDS] Setting up position stream');
      _subscription?.cancel();
      _subscription =
          geo.Geolocator.getPositionStream(
            locationSettings: geo.LocationSettings(
              accuracy: geo.LocationAccuracy.high,
              distanceFilter: 10, // Update every 10 meters
              timeLimit: interval,
            ),
          ).listen(
            (position) {
              if (GlobalConfig.logLocationUpdates) {
                debugPrint(
                  '[LocationDS] Position stream update: ${position.latitude}, ${position.longitude}, alt: ${position.altitude}m',
                );
              }
              // Emit position
              _positionController.add(
                Position(
                  latitude: position.latitude,
                  longitude: position.longitude,
                  altitude: position.altitude,
                ),
              );

              // Emit height measurement
              _heightController.add(
                HeightMeasurement(
                  heightMeters: position.altitude,
                  source: HeightSource.gps,
                  accuracy: position.altitudeAccuracy,
                  timestamp: DateTime.now(),
                  isReliable: position.altitudeAccuracy < 50,
                ),
              );
            },
            onError: (error) {
              debugPrint('[LocationDS] Location stream error: $error');
              _positionController.addError(
                LocationFailure(message: 'Location stream error: $error'),
              );
            },
          );

      debugPrint('[LocationDS] Location stream started successfully');
      return const Right(null);
    } catch (e) {
      debugPrint('[LocationDS] Failed to start location stream: $e');
      return Left(LocationFailure(message: 'Failed to start location: $e'));
    }
  }

  /// Stop listening to location updates
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Check and request location permission
  FutureResult<void> _checkPermission() async {
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(
          LocationFailure(
            message: 'Location services are disabled',
            code: 'service_disabled',
          ),
        );
      }

      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          return const Left(
            PermissionFailure(
              message: 'Location permission denied',
              code: 'permission_denied',
            ),
          );
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        return const Left(
          PermissionFailure(
            message: 'Location permission permanently denied',
            code: 'permission_denied_forever',
          ),
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(LocationFailure(message: 'Permission check failed: $e'));
    }
  }

  /// Check if location services are available
  Future<bool> isAvailable() async {
    try {
      return await geo.Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Request to open location settings
  Future<bool> openLocationSettings() async {
    return await geo.Geolocator.openLocationSettings();
  }

  /// Request to open app settings
  Future<bool> openAppSettings() async {
    return await geo.Geolocator.openAppSettings();
  }

  /// Dispose resources
  void dispose() {
    stopListening();
    _positionController.close();
    _heightController.close();
  }
}
