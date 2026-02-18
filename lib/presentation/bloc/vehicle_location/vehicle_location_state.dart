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

  const VehicleLocationUpdated({required this.locations});

  @override
  List<Object?> get props => [locations];
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
