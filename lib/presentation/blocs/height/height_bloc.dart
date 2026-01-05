import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import 'height_event.dart';
import 'height_state.dart';

/// BLoC for managing height/altitude data from multiple sensors
class HeightBloc extends Bloc<HeightEvent, HeightState> {
  final HeightRepository _heightRepository;
  final LocationRepository _locationRepository;

  StreamSubscription? _heightSubscription;
  Position? _currentPosition;

  HeightBloc({
    required HeightRepository heightRepository,
    required LocationRepository locationRepository,
  }) : _heightRepository = heightRepository,
       _locationRepository = locationRepository,
       super(const HeightInitial()) {
    on<StartHeightMonitoring>(_onStartMonitoring);
    on<StopHeightMonitoring>(_onStopMonitoring);
    on<HeightDataUpdated>(_onHeightDataUpdated);
    on<FetchApiElevation>(_onFetchApiElevation);
    on<HeightErrorOccurred>(_onHeightError);
  }

  Future<void> _onStartMonitoring(
    StartHeightMonitoring event,
    Emitter<HeightState> emit,
  ) async {
    debugPrint('[HeightBloc] Starting height monitoring');
    emit(const HeightLoading());

    try {
      // Check sensor availability
      debugPrint('[HeightBloc] Checking sensor availability');
      final availability = await _heightRepository.checkSensorAvailability();
      debugPrint('[HeightBloc] Sensor availability: $availability');

      // Get current position for API elevation
      debugPrint('[HeightBloc] Getting current position for API elevation');
      final positionResult = await _locationRepository.getCurrentPosition();
      _currentPosition = positionResult.fold(
        (failure) {
          debugPrint('[HeightBloc] Failed to get position: ${failure.message}');
          return null;
        },
        (position) {
          debugPrint(
            '[HeightBloc] Got position: ${position.latitude}, ${position.longitude}',
          );
          return position;
        },
      );

      // Start monitoring
      debugPrint('[HeightBloc] Starting sensor monitoring');
      await _heightRepository.startMonitoring();

      // Subscribe to height data updates
      _heightSubscription?.cancel();
      _heightSubscription = _heightRepository.heightDataStream.listen(
        (heightData) {
          debugPrint(
            '[HeightBloc] Height data received - GPS: ${heightData.gpsHeight?.heightMeters}m, Barometer: ${heightData.barometerHeight?.heightMeters}m, API: ${heightData.apiHeight?.heightMeters}m',
          );
          add(
            HeightDataUpdated(
              gpsHeight: heightData.gpsHeight?.heightMeters,
              barometerHeight: heightData.barometerHeight?.heightMeters,
              apiHeight: heightData.apiHeight?.heightMeters,
              gpsAccuracy: heightData.gpsHeight?.accuracy,
            ),
          );
        },
        onError: (error) {
          debugPrint('[HeightBloc] Height stream error: $error');
          add(HeightErrorOccurred(error.toString()));
        },
      );

      // Fetch API elevation if we have position
      if (_currentPosition != null) {
        debugPrint('[HeightBloc] Fetching API elevation for position');
        add(
          FetchApiElevation(
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
          ),
        );
      } else {
        debugPrint(
          '[HeightBloc] No position available yet - API elevation will be fetched later',
        );
      }

      emit(
        HeightLoaded(
          heightData: HeightData.empty(),
          sensorAvailability: availability,
          isMonitoring: true,
        ),
      );
    } catch (e) {
      emit(HeightError('Failed to start monitoring: $e'));
    }
  }

  Future<void> _onStopMonitoring(
    StopHeightMonitoring event,
    Emitter<HeightState> emit,
  ) async {
    _heightSubscription?.cancel();
    _heightRepository.stopMonitoring();

    if (state is HeightLoaded) {
      emit((state as HeightLoaded).copyWith(isMonitoring: false));
    }
  }

  void _onHeightDataUpdated(
    HeightDataUpdated event,
    Emitter<HeightState> emit,
  ) {
    final currentState = state;

    HeightData newData;
    Map<HeightSource, bool> availability;

    if (currentState is HeightLoaded) {
      newData = currentState.heightData;
      availability = currentState.sensorAvailability;
    } else {
      newData = HeightData.empty();
      availability = {};
    }

    // Update height data based on event
    if (event.gpsHeight != null) {
      newData = newData.copyWith(
        gpsHeight: HeightMeasurement(
          heightMeters: event.gpsHeight!,
          source: HeightSource.gps,
          accuracy: event.gpsAccuracy,
          timestamp: DateTime.now(),
          isReliable: (event.gpsAccuracy ?? 100) < 50,
        ),
      );
    }

    if (event.barometerHeight != null) {
      newData = newData.copyWith(
        barometerHeight: HeightMeasurement(
          heightMeters: event.barometerHeight!,
          source: HeightSource.barometer,
          timestamp: DateTime.now(),
          isReliable: true,
        ),
      );
    }

    if (event.apiHeight != null) {
      newData = newData.copyWith(
        apiHeight: HeightMeasurement(
          heightMeters: event.apiHeight!,
          source: HeightSource.api,
          timestamp: DateTime.now(),
          isReliable: true,
        ),
      );
    }

    emit(
      HeightLoaded(
        heightData: newData,
        sensorAvailability: availability,
        isMonitoring: true,
      ),
    );
  }

  Future<void> _onFetchApiElevation(
    FetchApiElevation event,
    Emitter<HeightState> emit,
  ) async {
    debugPrint(
      '[HeightBloc] Fetching API elevation for: ${event.latitude}, ${event.longitude}',
    );
    final position = Position(
      latitude: event.latitude,
      longitude: event.longitude,
    );

    final result = await _heightRepository.fetchElevationFromApi(position);

    result.fold(
      (failure) {
        debugPrint(
          '[HeightBloc] API elevation fetch failed: ${failure.message}',
        );
        // Silently fail - API elevation is optional
      },
      (measurement) {
        debugPrint(
          '[HeightBloc] API elevation fetched: ${measurement.heightMeters}m',
        );
        add(HeightDataUpdated(apiHeight: measurement.heightMeters));
      },
    );
  }

  void _onHeightError(HeightErrorOccurred event, Emitter<HeightState> emit) {
    // Log error but don't change state if we have data
    if (state is! HeightLoaded) {
      emit(HeightError(event.message));
    }
  }

  /// Update position for API elevation fetching
  void updatePosition(Position position) {
    debugPrint(
      '[HeightBloc] updatePosition called: ${position.latitude}, ${position.longitude}',
    );
    _currentPosition = position;
    add(
      FetchApiElevation(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
  }

  @override
  Future<void> close() {
    _heightSubscription?.cancel();
    return super.close();
  }
}
