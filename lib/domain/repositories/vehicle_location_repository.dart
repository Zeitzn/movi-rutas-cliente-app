import 'package:dartz/dartz.dart';
import 'package:cliente/core/errors/failures.dart';
import 'package:cliente/domain/entities/vehicle_location_entity.dart';

abstract class VehicleLocationRepository {
  Stream<Either<Failure, List<VehicleLocationEntity>>> listenVehicleLocations(
    String routeId,
  );

  Future<void> disconnect();
}
