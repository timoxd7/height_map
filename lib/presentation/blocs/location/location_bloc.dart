import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/repositories.dart';
import 'location_event.dart';
import 'location_state.dart';

/// BLoC for managing location tracking
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _locationRepository;
  StreamSubscription? _positionSubscription;

  LocationBloc({required LocationRepository locationRepository})
    : _locationRepository = locationRepository,
      super(const LocationInitial()) {
    on<StartLocationTracking>(_onStartTracking);
    on<StopLocationTracking>(_onStopTracking);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<LocationUpdated>(_onLocationUpdated);
    on<LocationErrorOccurred>(_onLocationError);
    on<OpenLocationSettings>(_onOpenLocationSettings);
  }

  Future<void> _onStartTracking(
    StartLocationTracking event,
    Emitter<LocationState> emit,
  ) async {
    debugPrint('[LocationBloc] Starting location tracking');
    emit(const LocationLoading());

    // Check if location service is available
    final isAvailable = await _locationRepository.isLocationAvailable();
    debugPrint('[LocationBloc] Location service available: $isAvailable');
    if (!isAvailable) {
      debugPrint('[LocationBloc] Location service disabled');
      emit(const LocationServiceDisabled());
      return;
    }

    // Start tracking
    debugPrint('[LocationBloc] Requesting location tracking start');
    final result = await _locationRepository.startTracking();

    await result.fold(
      (failure) async {
        debugPrint(
          '[LocationBloc] Location tracking failed: ${failure.message}, code: ${failure.code}',
        );
        if (failure.code == 'permission_denied') {
          emit(
            const LocationPermissionDenied(
              message: 'Location permission denied',
              isPermanent: false,
            ),
          );
        } else if (failure.code == 'permission_denied_forever') {
          emit(
            const LocationPermissionDenied(
              message: 'Location permission permanently denied',
              isPermanent: true,
            ),
          );
        } else {
          emit(LocationError(failure.message));
        }
      },
      (_) async {
        debugPrint('[LocationBloc] Location tracking started successfully');
        // Get initial position
        debugPrint('[LocationBloc] Getting initial position');
        final positionResult = await _locationRepository.getCurrentPosition();
        positionResult.fold(
          (failure) {
            debugPrint(
              '[LocationBloc] Failed to get initial position: ${failure.message}',
            );
            emit(LocationError(failure.message));
          },
          (position) {
            debugPrint(
              '[LocationBloc] Initial position: ${position.latitude}, ${position.longitude}, altitude: ${position.altitude}m',
            );
            emit(
              LocationLoaded(
                currentPosition: position,
                isTracking: true,
                lastUpdate: DateTime.now(),
              ),
            );
          },
        );

        // Subscribe to position updates
        _positionSubscription?.cancel();
        _positionSubscription = _locationRepository.positionStream.listen(
          (position) {
            debugPrint(
              '[LocationBloc] Position update: ${position.latitude}, ${position.longitude}',
            );
            add(LocationUpdated(position));
          },
          onError: (error) {
            debugPrint('[LocationBloc] Position stream error: $error');
            add(LocationErrorOccurred(error.toString()));
          },
        );
      },
    );
  }

  Future<void> _onStopTracking(
    StopLocationTracking event,
    Emitter<LocationState> emit,
  ) async {
    _positionSubscription?.cancel();
    _locationRepository.stopTracking();

    if (state is LocationLoaded) {
      emit((state as LocationLoaded).copyWith(isTracking: false));
    }
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<LocationState> emit,
  ) async {
    final currentState = state;

    if (currentState is! LocationLoaded) {
      emit(const LocationLoading());
    }

    final result = await _locationRepository.getCurrentPosition();

    result.fold(
      (failure) {
        if (failure.code == 'permission_denied') {
          emit(
            const LocationPermissionDenied(
              message: 'Location permission denied',
            ),
          );
        } else if (failure.code == 'service_disabled') {
          emit(const LocationServiceDisabled());
        } else {
          emit(LocationError(failure.message));
        }
      },
      (position) {
        emit(
          LocationLoaded(
            currentPosition: position,
            isTracking: currentState is LocationLoaded
                ? currentState.isTracking
                : false,
            lastUpdate: DateTime.now(),
          ),
        );
      },
    );
  }

  void _onLocationUpdated(LocationUpdated event, Emitter<LocationState> emit) {
    final currentState = state;

    if (currentState is LocationLoaded) {
      emit(
        currentState.copyWith(
          currentPosition: event.position,
          lastUpdate: DateTime.now(),
        ),
      );
    } else {
      emit(
        LocationLoaded(
          currentPosition: event.position,
          isTracking: true,
          lastUpdate: DateTime.now(),
        ),
      );
    }
  }

  void _onLocationError(
    LocationErrorOccurred event,
    Emitter<LocationState> emit,
  ) {
    // Don't override loaded state with error
    if (state is! LocationLoaded) {
      emit(LocationError(event.message));
    }
  }

  Future<void> _onOpenLocationSettings(
    OpenLocationSettings event,
    Emitter<LocationState> emit,
  ) async {
    final currentState = state;

    if (currentState is LocationPermissionDenied && currentState.isPermanent) {
      await _locationRepository.openAppSettings();
    } else {
      await _locationRepository.openLocationSettings();
    }
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
