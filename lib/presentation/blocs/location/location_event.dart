import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

/// Base class for all location-related events
abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start location tracking
class StartLocationTracking extends LocationEvent {
  const StartLocationTracking();
}

/// Event to stop location tracking
class StopLocationTracking extends LocationEvent {
  const StopLocationTracking();
}

/// Event to get current location once
class GetCurrentLocation extends LocationEvent {
  const GetCurrentLocation();
}

/// Event when location is updated
class LocationUpdated extends LocationEvent {
  final Position position;

  const LocationUpdated(this.position);

  @override
  List<Object?> get props => [position];
}

/// Event when location error occurs
class LocationErrorOccurred extends LocationEvent {
  final String message;

  const LocationErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}

/// Event to open location settings
class OpenLocationSettings extends LocationEvent {
  const OpenLocationSettings();
}
