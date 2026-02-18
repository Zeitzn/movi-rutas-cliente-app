import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  final String message;

  const ServerFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  final String message;

  const NetworkFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  final String message;

  const CacheFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class LocationPermissionFailure extends Failure {
  final String message;

  const LocationPermissionFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class WebSocketFailure extends Failure {
  final String message;

  const WebSocketFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
