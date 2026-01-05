import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/failure.dart';
import '../../core/utils/result.dart';
import '../models/models.dart';

/// Data source for fetching elevation data from Open Topo Data API
class ElevationApiDataSource {
  final Dio _dio;

  ElevationApiDataSource({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConstants.openTopoDataBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  /// Get elevation for a single point
  FutureResult<ElevationPoint> getElevation(Position position) async {
    debugPrint(
      '[ElevationAPI] Fetching elevation for: ${position.latitude}, ${position.longitude}',
    );
    try {
      final url =
          '${AppConstants.openTopoDataBaseUrl}/v1/${AppConstants.elevationDataset}?locations=${position.latitude},${position.longitude}';
      debugPrint('[ElevationAPI] Request URL: $url');

      final response = await _dio.get(
        '/v1/${AppConstants.elevationDataset}',
        queryParameters: {
          'locations': '${position.latitude},${position.longitude}',
        },
      );

      debugPrint('[ElevationAPI] Response status: ${response.statusCode}');
      debugPrint('[ElevationAPI] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List;

        if (results.isNotEmpty) {
          final result = results.first as Map<String, dynamic>;
          final elevation = result['elevation'];

          if (elevation != null) {
            debugPrint('[ElevationAPI] Elevation found: $elevation m');
            return Right(
              ElevationPoint(
                position: position,
                elevation: (elevation as num).toDouble(),
                dataset: result['dataset'] as String?,
              ),
            );
          }
        }

        debugPrint('[ElevationAPI] No elevation data in response');
        return const Left(
          ApiFailure(
            message: 'No elevation data available for this location',
            code: 'no_data',
          ),
        );
      }

      debugPrint(
        '[ElevationAPI] API request failed with status: ${response.statusCode}',
      );
      return Left(
        ApiFailure(
          message: 'API request failed',
          statusCode: response.statusCode,
        ),
      );
    } on DioException catch (e) {
      debugPrint(
        '[ElevationAPI] DioException: type=${e.type}, message=${e.message}, error=${e.error}',
      );
      return Left(_handleDioError(e));
    } catch (e) {
      debugPrint('[ElevationAPI] Unexpected error: $e');
      return Left(ApiFailure(message: 'Unexpected error: $e'));
    }
  }

  /// Get elevation for multiple points
  FutureResult<List<ElevationPoint>> getElevations(
    List<Position> positions,
  ) async {
    if (positions.isEmpty) {
      return const Right([]);
    }

    // API supports up to 100 points per request
    if (positions.length > 100) {
      return const Left(
        ApiFailure(
          message: 'Too many points (max 100)',
          code: 'too_many_points',
        ),
      );
    }

    try {
      final locations = positions
          .map((p) => '${p.latitude},${p.longitude}')
          .join('|');

      final response = await _dio.get(
        '/v1/${AppConstants.elevationDataset}',
        queryParameters: {'locations': locations},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List;

        final elevationPoints = <ElevationPoint>[];

        for (int i = 0; i < results.length; i++) {
          final result = results[i] as Map<String, dynamic>;
          final elevation = result['elevation'];

          if (elevation != null) {
            elevationPoints.add(
              ElevationPoint(
                position: positions[i],
                elevation: (elevation as num).toDouble(),
                dataset: result['dataset'] as String?,
              ),
            );
          }
        }

        return Right(elevationPoints);
      }

      return Left(
        ApiFailure(
          message: 'API request failed',
          statusCode: response.statusCode,
        ),
      );
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ApiFailure(message: 'Unexpected error: $e'));
    }
  }

  /// Handle Dio errors
  Failure _handleDioError(DioException e) {
    debugPrint('[ElevationAPI] Handling DioException: ${e.type}');
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          message: 'Connection timeout - please check your internet',
          code: 'timeout',
        );
      case DioExceptionType.connectionError:
        return NetworkFailure(
          message: 'No internet connection: ${e.error ?? "Connection failed"}',
          code: 'no_connection',
        );
      case DioExceptionType.badResponse:
        return ApiFailure(
          message:
              'Server error: ${e.response?.statusMessage ?? e.response?.statusCode}',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          message: 'SSL certificate error',
          code: 'ssl_error',
        );
      case DioExceptionType.cancel:
        return const NetworkFailure(
          message: 'Request was cancelled',
          code: 'cancelled',
        );
      case DioExceptionType.unknown:
        final errorMessage =
            e.message ?? e.error?.toString() ?? 'Unknown network error';
        return NetworkFailure(message: 'Network error: $errorMessage');
    }
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}
