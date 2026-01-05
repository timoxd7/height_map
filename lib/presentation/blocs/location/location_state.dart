import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

/// States for the location BLoC
abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

/// Initial state before location is determined
class LocationInitial extends LocationState {
  const LocationInitial();
}

/// State when location is being fetched
class LocationLoading extends LocationState {
  const LocationLoading();
}

/// State when location is available
class LocationLoaded extends LocationState {
  final Position currentPosition;
  final bool isTracking;
  final DateTime lastUpdate;

  const LocationLoaded({
    required this.currentPosition,
    required this.isTracking,
    required this.lastUpdate,
  });

  @override
  List<Object?> get props => [currentPosition, isTracking, lastUpdate];

  LocationLoaded copyWith({
    Position? currentPosition,
    bool? isTracking,
    DateTime? lastUpdate,
  }) {
    return LocationLoaded(
      currentPosition: currentPosition ?? this.currentPosition,
      isTracking: isTracking ?? this.isTracking,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

/// State when location permission is denied
class LocationPermissionDenied extends LocationState {
  final String message;
  final bool isPermanent;

  const LocationPermissionDenied({
    required this.message,
    this.isPermanent = false,
  });

  @override
  List<Object?> get props => [message, isPermanent];
}

/// State when location service is disabled
class LocationServiceDisabled extends LocationState {
  const LocationServiceDisabled();
}

/// State when there's an error
class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
}
