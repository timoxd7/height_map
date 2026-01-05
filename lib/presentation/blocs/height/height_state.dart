import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

/// States for the height BLoC
abstract class HeightState extends Equatable {
  const HeightState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class HeightInitial extends HeightState {
  const HeightInitial();
}

/// State when height monitoring is starting
class HeightLoading extends HeightState {
  const HeightLoading();
}

/// State when height data is available
class HeightLoaded extends HeightState {
  final HeightData heightData;
  final Map<HeightSource, bool> sensorAvailability;
  final bool isMonitoring;

  const HeightLoaded({
    required this.heightData,
    required this.sensorAvailability,
    required this.isMonitoring,
  });

  @override
  List<Object?> get props => [heightData, sensorAvailability, isMonitoring];

  /// Get the best available height value
  double? get bestHeight => heightData.bestMeasurement?.heightMeters;

  /// Get the source of the best height value
  HeightSource? get bestSource => heightData.bestMeasurement?.source;

  /// Copy with new values
  HeightLoaded copyWith({
    HeightData? heightData,
    Map<HeightSource, bool>? sensorAvailability,
    bool? isMonitoring,
  }) {
    return HeightLoaded(
      heightData: heightData ?? this.heightData,
      sensorAvailability: sensorAvailability ?? this.sensorAvailability,
      isMonitoring: isMonitoring ?? this.isMonitoring,
    );
  }
}

/// State when there's an error
class HeightError extends HeightState {
  final String message;

  const HeightError(this.message);

  @override
  List<Object?> get props => [message];
}
