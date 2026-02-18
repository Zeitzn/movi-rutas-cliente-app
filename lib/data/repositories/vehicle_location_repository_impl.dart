import 'package:dartz/dartz.dart';
import 'package:cliente/core/errors/failures.dart';
import 'package:cliente/core/errors/exceptions.dart';
import 'package:cliente/data/datasources/websocket/websocket_datasource_impl.dart';
import 'package:cliente/domain/entities/vehicle_location_entity.dart';
import 'package:cliente/domain/repositories/vehicle_location_repository.dart';

class VehicleLocationRepositoryImpl implements VehicleLocationRepository {
  final WebSocketDataSource webSocketDataSource;

  VehicleLocationRepositoryImpl({required this.webSocketDataSource});

  @override
  Stream<Either<Failure, List<VehicleLocationEntity>>> listenVehicleLocations(
    String routeId,
  ) async* {
    try {
      await webSocketDataSource.connect(
        'ws://192.168.1.100:3000/ws/routes/$routeId',
      );

      await for (final models in webSocketDataSource.listenVehicleLocations()) {
        final entities = models.map((model) => model.toEntity()).toList();
        yield Right(entities);
      }
    } on WebSocketException catch (e) {
      yield Left(WebSocketFailure(message: e.message));
    } catch (e) {
      yield Left(WebSocketFailure(message: e.toString()));
    }
  }

  @override
  Future<void> disconnect() async {
    webSocketDataSource.disconnect();
  }
}
