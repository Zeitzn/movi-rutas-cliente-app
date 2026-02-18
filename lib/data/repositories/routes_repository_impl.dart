import 'package:dartz/dartz.dart';
import 'package:cliente/core/errors/failures.dart';
import 'package:cliente/core/errors/exceptions.dart';
import 'package:cliente/data/datasources/remote/mock_routes_datasource.dart';
import 'package:cliente/domain/entities/route_entity.dart';
import 'package:cliente/domain/repositories/routes_repository.dart';

class RoutesRepositoryImpl implements RoutesRepository {
  final MockRoutesDataSource mockDataSource;

  RoutesRepositoryImpl({required this.mockDataSource});

  @override
  Future<Either<Failure, List<RouteEntity>>> getRoutes() async {
    try {
      final models = await mockDataSource.getRoutes();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
