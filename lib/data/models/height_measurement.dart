import 'package:equatable/equatable.dart';

/// Enum representing different height/altitude data sources
enum HeightSource {
  gps('GPS'),
  barometer('Barometer'),
  api('Elevation API'),
  unknown('Unknown');

  final String displayName;
  const HeightSource(this.displayName);
}

/// Model representing a height measurement from a specific source
class HeightMeasurement extends Equatable {
  /// The height value in meters
  final double heightMeters;

  /// The source of this measurement
  final HeightSource source;

  /// The accuracy of the measurement (if available)
  final double? accuracy;

  /// When this measurement was taken
  final DateTime timestamp;

  /// Whether this measurement is considered reliable
  final bool isReliable;

  const HeightMeasurement({
    required this.heightMeters,
    required this.source,
    this.accuracy,
    required this.timestamp,
    this.isReliable = true,
  });

  @override
  List<Object?> get props => [
    heightMeters,
    source,
    accuracy,
    timestamp,
    isReliable,
  ];

  /// Create a copy with optional new values
  HeightMeasurement copyWith({
    double? heightMeters,
    HeightSource? source,
    double? accuracy,
    DateTime? timestamp,
    bool? isReliable,
  }) {
    return HeightMeasurement(
      heightMeters: heightMeters ?? this.heightMeters,
      source: source ?? this.source,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      isReliable: isReliable ?? this.isReliable,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toJson() => {
    'heightMeters': heightMeters,
    'source': source.name,
    'accuracy': accuracy,
    'timestamp': timestamp.toIso8601String(),
    'isReliable': isReliable,
  };

  /// Create from Map
  factory HeightMeasurement.fromJson(Map<String, dynamic> json) =>
      HeightMeasurement(
        heightMeters: (json['heightMeters'] as num).toDouble(),
        source: HeightSource.values.firstWhere(
          (e) => e.name == json['source'],
          orElse: () => HeightSource.unknown,
        ),
        accuracy: json['accuracy'] != null
            ? (json['accuracy'] as num).toDouble()
            : null,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isReliable: json['isReliable'] as bool? ?? true,
      );

  @override
  String toString() =>
      'HeightMeasurement(${heightMeters.toStringAsFixed(1)}m from ${source.displayName})';
}

/// Model containing all available height measurements
class HeightData extends Equatable {
  final HeightMeasurement? gpsHeight;
  final HeightMeasurement? barometerHeight;
  final HeightMeasurement? apiHeight;

  const HeightData({this.gpsHeight, this.barometerHeight, this.apiHeight});

  @override
  List<Object?> get props => [gpsHeight, barometerHeight, apiHeight];

  /// Get all available measurements
  List<HeightMeasurement> get allMeasurements => [
    if (gpsHeight != null) gpsHeight!,
    if (barometerHeight != null) barometerHeight!,
    if (apiHeight != null) apiHeight!,
  ];

  /// Get the best (most reliable) measurement
  /// Priority: API > GPS > Barometer
  HeightMeasurement? get bestMeasurement {
    if (apiHeight?.isReliable == true) return apiHeight;
    if (gpsHeight?.isReliable == true) return gpsHeight;
    if (barometerHeight?.isReliable == true) return barometerHeight;
    return allMeasurements.isNotEmpty ? allMeasurements.first : null;
  }

  /// Check if any data is available
  bool get hasData => allMeasurements.isNotEmpty;

  /// Create a copy with optional new values
  HeightData copyWith({
    HeightMeasurement? gpsHeight,
    HeightMeasurement? barometerHeight,
    HeightMeasurement? apiHeight,
  }) {
    return HeightData(
      gpsHeight: gpsHeight ?? this.gpsHeight,
      barometerHeight: barometerHeight ?? this.barometerHeight,
      apiHeight: apiHeight ?? this.apiHeight,
    );
  }

  /// Create an empty HeightData
  factory HeightData.empty() => const HeightData();
}
