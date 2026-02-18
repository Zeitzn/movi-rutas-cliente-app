import 'package:cliente/domain/entities/vehicle_location_entity.dart';
import 'package:cliente/domain/repositories/vehicle_location_repository.dart';
import 'package:equatable/equatable.dart';

class ListenVehicleLocationsUseCase {
  final VehicleLocationRepository repository;

  ListenVehicleLocationsUseCase({required this.repository});

  Stream<List<VehicleLocationEntity>> call(String routeId) {
    return repository.listenVehicleLocations(routeId).map((result) {
      return result.fold((failure) => throw failure, (locations) => locations);
    });
  }
}

class ListenVehicleLocationsParams extends Equatable {
  final String routeId;

  const ListenVehicleLocationsParams({required this.routeId});

  @override
  List<Object?> get props => [routeId];
}
