import 'package:equatable/equatable.dart';
import 'package:cliente/domain/entities/vehicle_location_entity.dart';

abstract class VehicleLocationEvent extends Equatable {
  const VehicleLocationEvent();

  @override
  List<Object?> get props => [];
}

class RouteInfo extends Equatable {
  final String id;
  final String code;
  final int mainColor;

  const RouteInfo({
    required this.id,
    required this.code,
    required this.mainColor,
  });

  @override
  List<Object?> get props => [id, code, mainColor];
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

class AddRouteToListenEvent extends VehicleLocationEvent {
  final String routeId;

  const AddRouteToListenEvent({required this.routeId});

  @override
  List<Object?> get props => [routeId];
}

class RemoveRouteToListenEvent extends VehicleLocationEvent {
  final String routeId;

  const RemoveRouteToListenEvent({required this.routeId});

  @override
  List<Object?> get props => [routeId];
}

class UpdateSelectedRoutesEvent extends VehicleLocationEvent {
  final List<RouteInfo> routes;

  const UpdateSelectedRoutesEvent({required this.routes});

  @override
  List<Object?> get props => [routes];
}
