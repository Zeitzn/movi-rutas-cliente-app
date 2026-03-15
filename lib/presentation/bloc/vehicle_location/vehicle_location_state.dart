import 'package:equatable/equatable.dart';
import 'package:cliente/domain/entities/vehicle_location_entity.dart';

abstract class VehicleLocationState extends Equatable {
  const VehicleLocationState();

  @override
  List<Object?> get props => [];
}

class VehicleLocationInitial extends VehicleLocationState {
  const VehicleLocationInitial();
}

class VehicleLocationUpdated extends VehicleLocationState {
  final List<VehicleLocationEntity> locations;
  final bool isWebSocketConnected;

  const VehicleLocationUpdated({
    required this.locations,
    this.isWebSocketConnected = false,
  });

  @override
  List<Object?> get props => [locations, isWebSocketConnected];
}

class VehicleLocationError extends VehicleLocationState {
  final String message;

  const VehicleLocationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class VehicleLocationLoading extends VehicleLocationState {
  const VehicleLocationLoading();
}
