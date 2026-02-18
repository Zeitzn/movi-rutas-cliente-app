import 'package:equatable/equatable.dart';

abstract class UserLocationEvent extends Equatable {
  const UserLocationEvent();

  @override
  List<Object?> get props => [];
}

class RequestPermissionsEvent extends UserLocationEvent {
  const RequestPermissionsEvent();
}

class UpdateUserLocationEvent extends UserLocationEvent {
  final double latitude;
  final double longitude;

  const UpdateUserLocationEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class StartListeningLocationEvent extends UserLocationEvent {
  const StartListeningLocationEvent();
}

class EnableLocationServicesEvent extends UserLocationEvent {
  const EnableLocationServicesEvent();
}
