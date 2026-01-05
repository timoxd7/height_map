import 'package:equatable/equatable.dart';

/// Represents a geographic position with latitude and longitude
class Position extends Equatable {
  final double latitude;
  final double longitude;
  final double? altitude;

  const Position({
    required this.latitude,
    required this.longitude,
    this.altitude,
  });

  @override
  List<Object?> get props => [latitude, longitude, altitude];

  /// Create a copy with optional new values
  Position copyWith({double? latitude, double? longitude, double? altitude}) {
    return Position(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    if (altitude != null) 'altitude': altitude,
  };

  /// Create from Map
  factory Position.fromJson(Map<String, dynamic> json) => Position(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    altitude: json['altitude'] != null
        ? (json['altitude'] as num).toDouble()
        : null,
  );

  @override
  String toString() =>
      'Position($latitude, $longitude${altitude != null ? ', alt: ${altitude}m' : ''})';
}
