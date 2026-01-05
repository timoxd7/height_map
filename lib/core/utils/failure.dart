import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Failure for sensor-related errors
class SensorFailure extends Failure {
  const SensorFailure({required super.message, super.code});
}

/// Failure for location-related errors
class LocationFailure extends Failure {
  const LocationFailure({required super.message, super.code});
}

/// Failure for network-related errors
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Failure for permission-related errors
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}

/// Failure for API-related errors
class ApiFailure extends Failure {
  final int? statusCode;

  const ApiFailure({required super.message, super.code, this.statusCode});

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unknown error occurred',
    super.code,
  });
}
