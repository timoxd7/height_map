import 'package:equatable/equatable.dart';
import 'position.dart';

/// Model representing elevation data for a specific point
class ElevationPoint extends Equatable {
  final Position position;
  final double elevation;
  final String? dataset;

  const ElevationPoint({
    required this.position,
    required this.elevation,
    this.dataset,
  });

  @override
  List<Object?> get props => [position, elevation, dataset];

  /// Convert to Map
  Map<String, dynamic> toJson() => {
    'position': position.toJson(),
    'elevation': elevation,
    'dataset': dataset,
  };

  /// Create from Map
  factory ElevationPoint.fromJson(Map<String, dynamic> json) => ElevationPoint(
    position: Position.fromJson(json['position'] as Map<String, dynamic>),
    elevation: (json['elevation'] as num).toDouble(),
    dataset: json['dataset'] as String?,
  );

  @override
  String toString() =>
      'ElevationPoint(${elevation.toStringAsFixed(1)}m at $position)';
}

/// Model representing elevation comparison between two points
class ElevationComparison extends Equatable {
  final ElevationPoint currentLocation;
  final ElevationPoint selectedLocation;

  const ElevationComparison({
    required this.currentLocation,
    required this.selectedLocation,
  });

  @override
  List<Object?> get props => [currentLocation, selectedLocation];

  /// Get the elevation difference (selected - current)
  double get difference =>
      selectedLocation.elevation - currentLocation.elevation;

  /// Check if the selected location is higher
  bool get isHigher => difference > 0;

  /// Check if the selected location is lower
  bool get isLower => difference < 0;

  /// Check if the elevations are approximately equal (within 1m)
  bool get isEqual => difference.abs() < 1;
}
