import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import 'map_event.dart';
import 'map_state.dart';

/// BLoC for managing map interactions and elevation comparisons
class MapBloc extends Bloc<MapEvent, MapState> {
  final ElevationRepository _elevationRepository;

  MapBloc({required ElevationRepository elevationRepository})
    : _elevationRepository = elevationRepository,
      super(const MapInitial()) {
    on<MapTapped>(_onMapTapped);
    on<ClearSelectedPoint>(_onClearSelectedPoint);
    on<ElevationReceived>(_onElevationReceived);
    on<ElevationFetchError>(_onElevationFetchError);
    on<UpdateUserPosition>(_onUpdateUserPosition);
    on<CenterOnUser>(_onCenterOnUser);
    on<ZoomChanged>(_onZoomChanged);
    on<ToggleRotationMode>(_onToggleRotationMode);
    on<MapRotationChanged>(_onMapRotationChanged);
  }

  Future<void> _onMapTapped(MapTapped event, Emitter<MapState> emit) async {
    debugPrint(
      '[MapBloc] Map tapped at: ${event.position.latitude}, ${event.position.longitude}',
    );
    final currentState = _getOrCreateReadyState();
    debugPrint('[MapBloc] Current user position: ${currentState.userPosition}');

    // If no user position, we can only show selected point elevation
    if (currentState.userPosition == null) {
      emit(
        currentState.copyWith(
          selectedPosition: event.position,
          isLoadingElevation: true,
          clearElevation: true,
          clearError: true,
        ),
      );

      // Fetch just the selected point elevation
      debugPrint(
        '[MapBloc] Fetching single point elevation (no user position)',
      );
      final result = await _elevationRepository.getElevation(event.position);
      debugPrint('[MapBloc] Single elevation result: $result');
      result.fold(
        (failure) {
          debugPrint('[MapBloc] Elevation fetch failed: ${failure.message}');
          add(ElevationFetchError(failure.message));
        },
        (elevation) {
          debugPrint('[MapBloc] Elevation fetched: ${elevation.elevation}m');
          // Create a comparison with the same point (difference will be 0)
          add(
            ElevationReceived(
              ElevationComparison(
                currentLocation: elevation,
                selectedLocation: elevation,
              ),
            ),
          );
        },
      );
      return;
    }

    // Update state to show loading
    emit(
      currentState.copyWith(
        selectedPosition: event.position,
        isLoadingElevation: true,
        clearElevation: true,
        clearError: true,
      ),
    );

    // Fetch elevation comparison
    debugPrint('[MapBloc] Fetching elevation comparison');
    final result = await _elevationRepository.compareElevations(
      currentPosition: currentState.userPosition!,
      selectedPosition: event.position,
    );
    debugPrint('[MapBloc] Comparison result received');

    result.fold(
      (failure) {
        debugPrint('[MapBloc] Comparison failed: ${failure.message}');
        add(ElevationFetchError(failure.message));
      },
      (comparison) {
        debugPrint(
          '[MapBloc] Comparison success: current=${comparison.currentLocation.elevation}m, selected=${comparison.selectedLocation.elevation}m',
        );
        add(ElevationReceived(comparison));
      },
    );
  }

  void _onClearSelectedPoint(ClearSelectedPoint event, Emitter<MapState> emit) {
    final currentState = _getOrCreateReadyState();
    emit(
      currentState.copyWith(
        clearSelectedPosition: true,
        clearElevation: true,
        clearError: true,
      ),
    );
  }

  void _onElevationReceived(ElevationReceived event, Emitter<MapState> emit) {
    final currentState = _getOrCreateReadyState();
    emit(
      currentState.copyWith(
        elevationComparison: event.comparison,
        isLoadingElevation: false,
      ),
    );
  }

  void _onElevationFetchError(
    ElevationFetchError event,
    Emitter<MapState> emit,
  ) {
    final currentState = _getOrCreateReadyState();
    emit(
      currentState.copyWith(
        isLoadingElevation: false,
        errorMessage: event.message,
      ),
    );
  }

  void _onUpdateUserPosition(UpdateUserPosition event, Emitter<MapState> emit) {
    debugPrint(
      '[MapBloc] User position updated: ${event.position.latitude}, ${event.position.longitude}',
    );
    final currentState = _getOrCreateReadyState();
    emit(currentState.copyWith(userPosition: event.position));
  }

  void _onCenterOnUser(CenterOnUser event, Emitter<MapState> emit) {
    debugPrint('[MapBloc] CenterOnUser event received');
    final currentState = _getOrCreateReadyState();
    debugPrint('[MapBloc] User position: ${currentState.userPosition}');
    if (currentState.userPosition != null) {
      debugPrint('[MapBloc] Emitting shouldCenterOnUser = true');
      emit(currentState.copyWith(shouldCenterOnUser: true));
    } else {
      debugPrint('[MapBloc] No user position available - cannot center');
    }
  }

  void _onZoomChanged(ZoomChanged event, Emitter<MapState> emit) {
    final currentState = _getOrCreateReadyState();
    emit(currentState.copyWith(currentZoom: event.zoom));
  }

  void _onToggleRotationMode(
    ToggleRotationMode event,
    Emitter<MapState> emit,
  ) {
    final currentState = _getOrCreateReadyState();
    final currentMode = currentState.rotationMode;
    
    RotationMode newMode;
    double newRotation = currentState.mapRotation;
    
    switch (currentMode) {
      case RotationMode.free:
        // Transition from free to northOriented and reset rotation to north
        newMode = RotationMode.northOriented;
        newRotation = 0.0;
        break;
      case RotationMode.northOriented:
        // Transition from northOriented to locked
        newMode = RotationMode.locked;
        newRotation = 0.0;
        break;
      case RotationMode.locked:
        // Transition from locked to northOriented
        newMode = RotationMode.northOriented;
        newRotation = 0.0;
        break;
    }
    
    debugPrint('[MapBloc] Rotation mode changed: $currentMode -> $newMode');
    emit(currentState.copyWith(
      rotationMode: newMode,
      mapRotation: newRotation,
    ));
  }

  void _onMapRotationChanged(
    MapRotationChanged event,
    Emitter<MapState> emit,
  ) {
    final currentState = _getOrCreateReadyState();
    
    // If in northOriented mode and user rotates, switch to free mode
    if (currentState.rotationMode == RotationMode.northOriented) {
      debugPrint('[MapBloc] User rotated map, switching to free mode');
      emit(currentState.copyWith(
        rotationMode: RotationMode.free,
        mapRotation: event.rotation,
      ));
    } else if (currentState.rotationMode == RotationMode.free) {
      // Just update rotation in free mode
      emit(currentState.copyWith(mapRotation: event.rotation));
    }
    // In locked mode, ignore rotation changes
  }

  /// Helper to get current state as MapReady or create a new one
  MapReady _getOrCreateReadyState() {
    if (state is MapReady) {
      return state as MapReady;
    }
    return const MapReady();
  }
}
