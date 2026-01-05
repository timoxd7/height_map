import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/result.dart';
import '../../core/utils/failure.dart';
import '../datasources/datasources.dart';
import '../models/models.dart';

/// Repository for fetching elevation data
class ElevationRepository {
  final ElevationApiDataSource _apiDataSource;

  ElevationRepository({required ElevationApiDataSource apiDataSource})
    : _apiDataSource = apiDataSource;

  /// Get elevation for a single point
  FutureResult<ElevationPoint> getElevation(Position position) {
    debugPrint(
      '[ElevationRepo] Getting elevation for: ${position.latitude}, ${position.longitude}',
    );
    return _apiDataSource.getElevation(position);
  }

  /// Get elevations for multiple points
  FutureResult<List<ElevationPoint>> getElevations(List<Position> positions) {
    debugPrint(
      '[ElevationRepo] Getting elevations for ${positions.length} points',
    );
    return _apiDataSource.getElevations(positions);
  }

  /// Get elevation comparison between current location and selected point
  FutureResult<ElevationComparison> compareElevations({
    required Position currentPosition,
    required Position selectedPosition,
  }) async {
    debugPrint('[ElevationRepo] Comparing elevations');
    debugPrint(
      '[ElevationRepo] Current: ${currentPosition.latitude}, ${currentPosition.longitude}',
    );
    debugPrint(
      '[ElevationRepo] Selected: ${selectedPosition.latitude}, ${selectedPosition.longitude}',
    );

    // Fetch both elevations
    final results = await _apiDataSource.getElevations([
      currentPosition,
      selectedPosition,
    ]);

    return results.fold(
      (failure) {
        debugPrint(
          '[ElevationRepo] Failed to get elevations: ${failure.message}',
        );
        return Left(failure);
      },
      (elevations) {
        debugPrint('[ElevationRepo] Got ${elevations.length} elevations');
        if (elevations.length < 2) {
          debugPrint(
            '[ElevationRepo] Incomplete data - less than 2 elevations',
          );
          return const Left(
            ApiFailure(
              message: 'Could not get elevations for both points',
              code: 'incomplete_data',
            ),
          );
        }

        debugPrint(
          '[ElevationRepo] Comparison: current=${elevations[0].elevation}m, selected=${elevations[1].elevation}m',
        );
        return Right(
          ElevationComparison(
            currentLocation: elevations[0],
            selectedLocation: elevations[1],
          ),
        );
      },
    );
  }

  /// Dispose resources
  void dispose() {
    _apiDataSource.dispose();
  }
}
