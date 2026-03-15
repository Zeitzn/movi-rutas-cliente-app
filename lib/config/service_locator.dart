import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

// Core
import 'package:cliente/core/network/api_client.dart';
import 'package:cliente/core/network/websocket_service.dart';
import 'package:cliente/core/permissions/location_permission_service.dart';
import 'package:cliente/services/websocket_subscriber_service.dart';

// Data
import 'package:cliente/data/datasources/remote/mock_routes_datasource.dart';
import 'package:cliente/data/datasources/websocket/websocket_datasource_impl.dart';
import 'package:cliente/data/repositories/routes_repository_impl.dart';
import 'package:cliente/data/repositories/vehicle_location_repository_impl.dart';

// Domain
import 'package:cliente/domain/repositories/routes_repository.dart';
import 'package:cliente/domain/repositories/vehicle_location_repository.dart';
import 'package:cliente/domain/usecases/get_routes_usecase.dart';
import 'package:cliente/domain/usecases/listen_vehicle_locations_usecase.dart';

// Presentation
import 'package:cliente/presentation/bloc/route_selection/route_selection_bloc.dart';
import 'package:cliente/presentation/bloc/websocket/websocket_bloc.dart';
import 'package:cliente/presentation/bloc/vehicle_location/vehicle_location_bloc.dart';
import 'package:cliente/presentation/bloc/user_location/user_location_bloc.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Core - Network
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerSingleton<ApiClient>(ApiClientImpl(dio: getIt<Dio>()));
  getIt.registerSingleton<WebSocketService>(WebSocketServiceImpl());

  // Core - Permissions
  getIt.registerSingleton<LocationPermissionService>(
    LocationPermissionServiceImpl(),
  );

  // Data - DataSources
  getIt.registerSingleton<MockRoutesDataSource>(MockRoutesDataSourceImpl());
  getIt.registerSingleton<WebSocketDataSource>(
    WebSocketDataSourceImpl(webSocketService: getIt<WebSocketService>()),
  );

  // Data - Repositories
  getIt.registerSingleton<RoutesRepository>(
    RoutesRepositoryImpl(mockDataSource: getIt<MockRoutesDataSource>()),
  );
  getIt.registerSingleton<VehicleLocationRepository>(
    VehicleLocationRepositoryImpl(
      webSocketDataSource: getIt<WebSocketDataSource>(),
    ),
  );

  // Domain - UseCases
  getIt.registerSingleton<GetRoutesUseCase>(
    GetRoutesUseCase(repository: getIt<RoutesRepository>()),
  );
  getIt.registerSingleton<ListenVehicleLocationsUseCase>(
    ListenVehicleLocationsUseCase(
      repository: getIt<VehicleLocationRepository>(),
    ),
  );

  // Presentation - BLoCs
  getIt.registerSingleton<RouteSelectionBloc>(
    RouteSelectionBloc(getRoutesUseCase: getIt<GetRoutesUseCase>()),
  );
  getIt.registerSingleton<WebSocketBloc>(
    WebSocketBloc(webSocketService: getIt<WebSocketService>()),
  );
  getIt.registerSingleton<WebSocketSubscriberService>(
    WebSocketSubscriberService(),
  );
  getIt.registerSingleton<VehicleLocationBloc>(
    VehicleLocationBloc(
      repository: getIt<VehicleLocationRepository>(),
      webSocketService: getIt<WebSocketSubscriberService>(),
    ),
  );
  getIt.registerSingleton<UserLocationBloc>(
    UserLocationBloc(
      locationPermissionService: getIt<LocationPermissionService>(),
    ),
  );
}
