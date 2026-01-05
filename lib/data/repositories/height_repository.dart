import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../core/config/global_config.dart';
import '../../core/utils/result.dart';
import '../datasources/datasources.dart';
import '../models/models.dart';

/// Repository for managing height/altitude data from multiple sources
class HeightRepository {
  final BarometerDataSource _barometerDataSource;
  final LocationDataSource _locationDataSource;
  final ElevationApiDataSource _elevationApiDataSource;

  final _heightDataController = StreamController<HeightData>.broadcast();
  HeightData _currentData = HeightData.empty();

  HeightRepository({
    required BarometerDataSource barometerDataSource,
    required LocationDataSource locationDataSource,
    required ElevationApiDataSource elevationApiDataSource,
  }) : _barometerDataSource = barometerDataSource,
       _locationDataSource = locationDataSource,
       _elevationApiDataSource = elevationApiDataSource;

  /// Stream of combined height data from all sources
  Stream<HeightData> get heightDataStream => _heightDataController.stream;

  /// Get current height data
  HeightData get currentHeightData => _currentData;

  /// Initialize and start listening to all sensors
  Future<void> startMonitoring() async {
    debugPrint('[HeightRepo] Starting sensor monitoring');

    // Start barometer
    debugPrint('[HeightRepo] Starting barometer');
    await _barometerDataSource.startListening();
    _barometerDataSource.heightStream.listen((measurement) {
      if (GlobalConfig.logBarometerReadings) {
        debugPrint(
          '[HeightRepo] Barometer height: ${measurement.heightMeters}m',
        );
      }
      _currentData = _currentData.copyWith(barometerHeight: measurement);
      _heightDataController.add(_currentData);
    }, onError: (e) => debugPrint('[HeightRepo] Barometer stream error: $e'));

    // Start GPS
    debugPrint('[HeightRepo] Starting GPS');
    await _locationDataSource.startListening();
    _locationDataSource.heightStream.listen((measurement) {
      if (GlobalConfig.logGpsReadings) {
        debugPrint('[HeightRepo] GPS height: ${measurement.heightMeters}m');
      }
      _currentData = _currentData.copyWith(gpsHeight: measurement);
      _heightDataController.add(_currentData);
    }, onError: (e) => debugPrint('[HeightRepo] GPS height stream error: $e'));

    debugPrint('[HeightRepo] Sensor monitoring started');
  }

  /// Stop all sensor monitoring
  void stopMonitoring() {
    _barometerDataSource.stopListening();
    _locationDataSource.stopListening();
  }

  /// Get elevation from API for current position
  FutureResult<HeightMeasurement> fetchElevationFromApi(
    Position position,
  ) async {
    debugPrint(
      '[HeightRepo] Fetching elevation from API for: ${position.latitude}, ${position.longitude}',
    );
    final result = await _elevationApiDataSource.getElevation(position);
    return result.fold(
      (failure) {
        debugPrint(
          '[HeightRepo] API elevation fetch failed: ${failure.message}',
        );
        return Left(failure);
      },
      (elevation) {
        debugPrint(
          '[HeightRepo] API elevation received: ${elevation.elevation}m',
        );
        final measurement = HeightMeasurement(
          heightMeters: elevation.elevation,
          source: HeightSource.api,
          timestamp: DateTime.now(),
          isReliable: true,
        );
        _currentData = _currentData.copyWith(apiHeight: measurement);
        _heightDataController.add(_currentData);
        return Right(measurement);
      },
    );
  }

  /// Check sensor availability
  Future<Map<HeightSource, bool>> checkSensorAvailability() async {
    final barometerAvailable = await _barometerDataSource.isAvailable();
    final gpsAvailable = await _locationDataSource.isAvailable();

    return {
      HeightSource.barometer: barometerAvailable,
      HeightSource.gps: gpsAvailable,
      HeightSource.api: true, // API is always "available" if there's internet
    };
  }

  /// Calibrate barometer with known altitude
  void calibrateBarometer(double knownAltitude, double currentPressure) {
    // Calculate sea level pressure based on known altitude and current pressure
    // P0 = P / (1 - h/44330)^5.255
    final seaLevelPressure =
        currentPressure / (1.0 - (knownAltitude / 44330.0)).abs();
    _barometerDataSource.setSeaLevelPressure(seaLevelPressure);
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _heightDataController.close();
    _barometerDataSource.dispose();
    _locationDataSource.dispose();
    _elevationApiDataSource.dispose();
  }
}
