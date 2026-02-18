import 'package:cliente/core/network/api_client.dart';
import 'package:cliente/data/models/route_model.dart';
import 'package:cliente/core/constants/app_constants.dart';
import 'package:cliente/core/errors/exceptions.dart';

abstract class RoutesRemoteDataSource {
  Future<List<RouteModel>> getRoutes();
}

class RoutesRemoteDataSourceImpl implements RoutesRemoteDataSource {
  final ApiClient apiClient;

  RoutesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<RouteModel>> getRoutes() async {
    try {
      final data = await apiClient.get(AppConstants.routesEndpoint);

      if (data is List) {
        return (data as List)
            .map((item) => RouteModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data.containsKey('routes')) {
        final routes = data['routes'] as List;
        return routes
            .map((item) => RouteModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(message: 'Invalid response format');
    } catch (e) {
      throw ServerException(message: 'Error: ${e.toString()}');
    }
  }
}
