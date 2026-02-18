import 'package:equatable/equatable.dart';

abstract class UserLocationState extends Equatable {
  const UserLocationState();

  @override
  List<Object?> get props => [];
}

class UserLocationInitial extends UserLocationState {
  const UserLocationInitial();
}

class UserLocationLoading extends UserLocationState {
  const UserLocationLoading();
}

class UserLocationUpdated extends UserLocationState {
  final double latitude;
  final double longitude;

  const UserLocationUpdated({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class UserLocationError extends UserLocationState {
  final String message;

  const UserLocationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class UserLocationPermissionDenied extends UserLocationState {
  const UserLocationPermissionDenied();
}
