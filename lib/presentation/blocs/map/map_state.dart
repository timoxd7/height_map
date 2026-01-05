import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

/// Rotation lock modes for the map
enum RotationMode {
  /// Free rotation with compass needle showing current orientation
  free,

  /// North-oriented with compass needle
  northOriented,

  /// Locked to north with lock icon
  locked,
}

/// States for the map BLoC
abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

/// Initial map state
class MapInitial extends MapState {
  const MapInitial();
}

/// State when map is ready
class MapReady extends MapState {
  final Position? userPosition;
  final Position? selectedPosition;
  final ElevationComparison? elevationComparison;
  final bool isLoadingElevation;
  final String? errorMessage;
  final double currentZoom;
  final bool shouldCenterOnUser;
  final bool shouldZoomOnUser;
  final RotationMode rotationMode;
  final double mapRotation;

  const MapReady({
    this.userPosition,
    this.selectedPosition,
    this.elevationComparison,
    this.isLoadingElevation = false,
    this.errorMessage,
    this.currentZoom = 13.0,
    this.shouldCenterOnUser = false,
    this.shouldZoomOnUser = false,
    this.rotationMode = RotationMode.free,
    this.mapRotation = 0.0,
  });

  @override
  List<Object?> get props => [
    userPosition,
    selectedPosition,
    elevationComparison,
    isLoadingElevation,
    errorMessage,
    currentZoom,
    shouldCenterOnUser,
    shouldZoomOnUser,
    rotationMode,
    mapRotation,
  ];

  MapReady copyWith({
    Position? userPosition,
    Position? selectedPosition,
    ElevationComparison? elevationComparison,
    bool? isLoadingElevation,
    String? errorMessage,
    double? currentZoom,
    bool? shouldCenterOnUser,
    bool? shouldZoomOnUser,
    RotationMode? rotationMode,
    double? mapRotation,
    bool clearSelectedPosition = false,
    bool clearElevation = false,
    bool clearError = false,
  }) {
    return MapReady(
      userPosition: userPosition ?? this.userPosition,
      selectedPosition: clearSelectedPosition
          ? null
          : (selectedPosition ?? this.selectedPosition),
      elevationComparison: clearElevation
          ? null
          : (elevationComparison ?? this.elevationComparison),
      isLoadingElevation: isLoadingElevation ?? this.isLoadingElevation,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentZoom: currentZoom ?? this.currentZoom,
      shouldCenterOnUser: shouldCenterOnUser ?? false,
      shouldZoomOnUser: shouldZoomOnUser ?? false,
      rotationMode: rotationMode ?? this.rotationMode,
      mapRotation: mapRotation ?? this.mapRotation,
    );
  }

  /// Check if a point is selected
  bool get hasSelectedPoint => selectedPosition != null;

  /// Get elevation difference if available
  double? get elevationDifference => elevationComparison?.difference;

  /// Get selected point elevation if available
  double? get selectedElevation =>
      elevationComparison?.selectedLocation.elevation;

  /// Get current location elevation if available
  double? get currentElevation =>
      elevationComparison?.currentLocation.elevation;
}
