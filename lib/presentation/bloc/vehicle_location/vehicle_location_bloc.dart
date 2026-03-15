import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cliente/domain/entities/vehicle_location_entity.dart';
import 'package:cliente/domain/repositories/vehicle_location_repository.dart';
import 'package:cliente/presentation/bloc/vehicle_location/vehicle_location_event.dart';
import 'package:cliente/presentation/bloc/vehicle_location/vehicle_location_state.dart';
import 'package:cliente/services/websocket_subscriber_service.dart';

class VehicleLocationBloc
    extends Bloc<VehicleLocationEvent, VehicleLocationState> {
  final VehicleLocationRepository repository;
  final WebSocketSubscriberService _webSocketService;
  final Map<String, VehicleLocationEntity> _vehicleLocations = {};
  final Map<String, RouteInfo> _routeInfoByCode = {};

  VehicleLocationBloc({
    required this.repository,
    required WebSocketSubscriberService webSocketService,
  }) : _webSocketService = webSocketService,
       super(const VehicleLocationInitial()) {
    on<ListenVehicleLocationsEvent>(_onListenVehicleLocations);
    on<UpdateVehicleLocationEvent>(_onUpdateVehicleLocation);
    on<ClearLocationsEvent>(_onClearLocations);
    on<StartWebSocketListeningEvent>(_onStartWebSocketListening);
    on<StopWebSocketListeningEvent>(_onStopWebSocketListening);
    on<AddRouteToListenEvent>(_onAddRouteToListen);
    on<RemoveRouteToListenEvent>(_onRemoveRouteToListen);
    on<UpdateSelectedRoutesEvent>(_onUpdateSelectedRoutes);

    _webSocketService.addListener(_onWebSocketMessageReceived);
  }

  Set<String> get selectedRoutes => _routeInfoByCode.keys.toSet();

  void _onWebSocketMessageReceived(WebSocketMessage wsMessage) {
    final message = wsMessage.data;
    final routeCode = wsMessage.routeId;
    final remitente = message['remitente'] as String?;
    final latitud = message['latitud'] as double?;
    final longitud = message['longitud'] as double?;

    if (latitud != null && longitud != null) {
      final placa = remitente ?? 'Unknown';
      final routeInfo = _routeInfoByCode[routeCode];

      _vehicleLocations['${routeCode}_$placa'] = VehicleLocationEntity(
        latitude: latitud,
        longitude: longitud,
        placa: placa,
        timestamp: DateTime.now(),
        routeCode: routeCode,
        color: routeInfo?.mainColor ?? 0xFFFF5722,
      );

      add(
        UpdateVehicleLocationEvent(
          locations: _vehicleLocations.values.toList(),
        ),
      );
    }
  }

  Future<void> _onStartWebSocketListening(
    StartWebSocketListeningEvent event,
    Emitter<VehicleLocationState> emit,
  ) async {
    try {
      await _webSocketService.connect();
      for (final routeInfo in _routeInfoByCode.values) {
        _webSocketService.subscribeToRoute(routeInfo.code);
      }
      emit(
        VehicleLocationUpdated(
          locations: _vehicleLocations.values.toList(),
          isWebSocketConnected: true,
        ),
      );
    } catch (e) {
      emit(VehicleLocationError(message: e.toString()));
    }
  }

  Future<void> _onStopWebSocketListening(
    StopWebSocketListeningEvent event,
    Emitter<VehicleLocationState> emit,
  ) async {
    _vehicleLocations.clear();
    await _webSocketService.disconnect();
    emit(const VehicleLocationInitial());
  }

  Future<void> _onAddRouteToListen(
    AddRouteToListenEvent event,
    Emitter<VehicleLocationState> emit,
  ) async {
    final routeInfo = _routeInfoByCode[event.routeId];
    if (routeInfo != null && _webSocketService.isConnected) {
      _webSocketService.subscribeToRoute(routeInfo.code);
    }
    emit(
      VehicleLocationUpdated(
        locations: _vehicleLocations.values.toList(),
        isWebSocketConnected: _webSocketService.isConnected,
      ),
    );
  }

  Future<void> _onRemoveRouteToListen(
    RemoveRouteToListenEvent event,
    Emitter<VehicleLocationState> emit,
  ) async {
    final routeInfo = _routeInfoByCode[event.routeId];
    if (routeInfo != null) {
      _webSocketService.unsubscribeFromRoute(routeInfo.code);
      _vehicleLocations.removeWhere(
        (key, value) => key.startsWith('${routeInfo.code}_'),
      );
    }
    _routeInfoByCode.remove(event.routeId);

    emit(
      VehicleLocationUpdated(
        locations: _vehicleLocations.values.toList(),
        isWebSocketConnected: _webSocketService.isConnected,
      ),
    );
  }

  Future<void> _onUpdateSelectedRoutes(
    UpdateSelectedRoutesEvent event,
    Emitter<VehicleLocationState> emit,
  ) async {
    final previousCodes = Set<String>.from(_routeInfoByCode.keys);

    _routeInfoByCode.clear();
    for (final route in event.routes) {
      _routeInfoByCode[route.id] = route;
    }

    final newCodes = Set<String>.from(
      _routeInfoByCode.values.map((r) => r.code),
    );

    final routesToAdd = newCodes.difference(previousCodes);
    final routesToRemove = previousCodes.difference(newCodes);

    if (!_webSocketService.isConnected && newCodes.isNotEmpty) {
      try {
        await _webSocketService.connect();
      } catch (e) {
        emit(VehicleLocationError(message: e.toString()));
        return;
      }
    }

    for (final code in routesToAdd) {
      if (_webSocketService.isConnected) {
        _webSocketService.subscribeToRoute(code);
      }
    }

    for (final code in routesToRemove) {
      _webSocketService.unsubscribeFromRoute(code);
      _vehicleLocations.removeWhere((key, value) => key.startsWith('${code}_'));
    }

    if (_routeInfoByCode.isEmpty) {
      await _webSocketService.disconnect();
      emit(const VehicleLocationInitial());
    } else {
      emit(
        VehicleLocationUpdated(
          locations: _vehicleLocations.values.toList(),
          isWebSocketConnected: _webSocketService.isConnected,
        ),
      );
    }
  }

  Future<void> _onListenVehicleLocations(
    ListenVehicleLocationsEvent event,
    Emitter<VehicleLocationState> emit,
  ) async {
    emit(const VehicleLocationLoading());

    await emit.forEach(
      repository.listenVehicleLocations(event.routeId),
      onData: (result) {
        return result.fold(
          (failure) => VehicleLocationError(message: failure.toString()),
          (locations) => VehicleLocationUpdated(
            locations: locations,
            isWebSocketConnected: _webSocketService.isConnected,
          ),
        );
      },
      onError: (error, stackTrace) {
        return VehicleLocationError(message: error.toString());
      },
    );
  }

  Future<void> _onUpdateVehicleLocation(
    UpdateVehicleLocationEvent event,
    Emitter<VehicleLocationState> emit,
  ) async {
    emit(
      VehicleLocationUpdated(
        locations: event.locations,
        isWebSocketConnected: _webSocketService.isConnected,
      ),
    );
  }

  Future<void> _onClearLocations(
    ClearLocationsEvent event,
    Emitter<VehicleLocationState> emit,
  ) async {
    _vehicleLocations.clear();
    emit(const VehicleLocationInitial());
  }
}
