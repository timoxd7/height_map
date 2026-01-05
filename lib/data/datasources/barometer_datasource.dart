import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:dartz/dartz.dart';
import '../../core/utils/failure.dart';
import '../../core/utils/result.dart';
import '../models/height_measurement.dart';

/// Data source for barometer sensor readings
class BarometerDataSource {
  StreamSubscription<BarometerEvent>? _subscription;
  final _controller = StreamController<HeightMeasurement>.broadcast();

  /// Standard sea level pressure in hPa
  double _seaLevelPressure = 1013.25;

  /// Stream of barometer height measurements
  Stream<HeightMeasurement> get heightStream => _controller.stream;

  /// Set the sea level pressure for calibration
  void setSeaLevelPressure(double pressure) {
    _seaLevelPressure = pressure;
  }

  /// Calculate altitude from barometric pressure
  /// Uses the barometric formula: h = 44330 * (1 - (P/P0)^(1/5.255))
  double _calculateAltitude(double pressureHPa) {
    return 44330.0 *
        (1.0 - math.pow(pressureHPa / _seaLevelPressure, 1.0 / 5.255));
  }

  /// Start listening to barometer events
  FutureResult<void> startListening() async {
    try {
      _subscription?.cancel();
      _subscription = barometerEventStream().listen(
        (event) {
          final altitude = _calculateAltitude(event.pressure);
          final measurement = HeightMeasurement(
            heightMeters: altitude,
            source: HeightSource.barometer,
            timestamp: DateTime.now(),
            isReliable: true,
          );
          _controller.add(measurement);
        },
        onError: (error) {
          _controller.addError(
            SensorFailure(message: 'Barometer error: $error'),
          );
        },
      );
      return const Right(null);
    } catch (e) {
      return Left(SensorFailure(message: 'Failed to start barometer: $e'));
    }
  }

  /// Stop listening to barometer events
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Check if barometer is available
  Future<bool> isAvailable() async {
    try {
      // Try to get a single reading to check availability
      await barometerEventStream().first.timeout(
        const Duration(seconds: 2),
        onTimeout: () => throw TimeoutException('Barometer not available'),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    stopListening();
    _controller.close();
  }
}
