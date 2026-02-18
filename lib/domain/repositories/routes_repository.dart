import 'package:dartz/dartz.dart';
import 'package:cliente/core/errors/failures.dart';
import 'package:cliente/domain/entities/route_entity.dart';

abstract class RoutesRepository {
  Future<Either<Failure, List<RouteEntity>>> getRoutes();
}
