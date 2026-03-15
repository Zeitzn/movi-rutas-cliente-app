import 'package:equatable/equatable.dart';
import 'package:cliente/domain/entities/vehicle_location_entity.dart';

abstract class VehicleLocationEvent extends Equatable {
  const VehicleLocationEvent();

  @override
  List<Object?> get props => [];
}

class UpdateVehicleLocationEvent extends VehicleLocationEvent {
  final List<VehicleLocationEntity> locations;

  const UpdateVehicleLocationEvent({required this.locations});

  @override
  List<Object?> get props => [locations];
}

class ClearLocationsEvent extends VehicleLocationEvent {
  const ClearLocationsEvent();
}

class ListenVehicleLocationsEvent extends VehicleLocationEvent {
  final String routeId;

  const ListenVehicleLocationsEvent({required this.routeId});

  @override
  List<Object?> get props => [routeId];
}

class StartWebSocketListeningEvent extends VehicleLocationEvent {
  const StartWebSocketListeningEvent();
}

class StopWebSocketListeningEvent extends VehicleLocationEvent {
  const StopWebSocketListeningEvent();
}
