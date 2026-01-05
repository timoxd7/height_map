import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

/// Base class for all map-related events
abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// Event when user taps on the map
class MapTapped extends MapEvent {
  final Position position;

  const MapTapped(this.position);

  @override
  List<Object?> get props => [position];
}

/// Event to clear the selected point
class ClearSelectedPoint extends MapEvent {
  const ClearSelectedPoint();
}

/// Event when elevation data is received for selected point
class ElevationReceived extends MapEvent {
  final ElevationComparison comparison;

  const ElevationReceived(this.comparison);

  @override
  List<Object?> get props => [comparison];
}

/// Event when there's an error fetching elevation
class ElevationFetchError extends MapEvent {
  final String message;

  const ElevationFetchError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Event to update current user position on map
class UpdateUserPosition extends MapEvent {
  final Position position;

  const UpdateUserPosition(this.position);

  @override
  List<Object?> get props => [position];
}

/// Event to center map on user location
class CenterOnUser extends MapEvent {
  const CenterOnUser();
}

/// Event to change map zoom level
class ZoomChanged extends MapEvent {
  final double zoom;

  const ZoomChanged(this.zoom);

  @override
  List<Object?> get props => [zoom];
}
