import 'package:dartz/dartz.dart';
import 'package:cliente/core/errors/failures.dart';
import 'package:cliente/core/usecases/usecase.dart';
import 'package:cliente/domain/entities/route_entity.dart';
import 'package:cliente/domain/repositories/routes_repository.dart';

class GetRoutesUseCase implements UseCase<List<RouteEntity>, NoParams> {
  final RoutesRepository repository;

  GetRoutesUseCase({required this.repository});

  @override
  Future<Either<Failure, List<RouteEntity>>> call(NoParams params) async {
    return await repository.getRoutes();
  }
}
