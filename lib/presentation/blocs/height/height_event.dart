import 'package:equatable/equatable.dart';

/// Base class for all height-related events
abstract class HeightEvent extends Equatable {
  const HeightEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start monitoring height from all sensors
class StartHeightMonitoring extends HeightEvent {
  const StartHeightMonitoring();
}

/// Event to stop monitoring height
class StopHeightMonitoring extends HeightEvent {
  const StopHeightMonitoring();
}

/// Event when height data is updated
class HeightDataUpdated extends HeightEvent {
  final double? gpsHeight;
  final double? barometerHeight;
  final double? apiHeight;
  final double? gpsAccuracy;

  const HeightDataUpdated({
    this.gpsHeight,
    this.barometerHeight,
    this.apiHeight,
    this.gpsAccuracy,
  });

  @override
  List<Object?> get props => [
    gpsHeight,
    barometerHeight,
    apiHeight,
    gpsAccuracy,
  ];
}

/// Event to fetch elevation from API for current position
class FetchApiElevation extends HeightEvent {
  final double latitude;
  final double longitude;

  const FetchApiElevation({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Event when an error occurs
class HeightErrorOccurred extends HeightEvent {
  final String message;

  const HeightErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}
