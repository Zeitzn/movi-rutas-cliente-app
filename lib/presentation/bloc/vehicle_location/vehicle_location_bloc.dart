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
  final Set<String> _selectedRoutes = {};

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

  Set<String> get selectedRoutes => _selectedRoutes;

  void _onWebSocketMessageReceived(Map<String, dynamic> message) {
    final remitente = message['remitente'] as String?;
    final latitud = message['latitud'] as double?;
    final longitud = message['longitud'] as double?;

    if (latitud != null && longitud != null) {
      final placa = remitente ?? 'Unknown';
      _vehicleLocations[placa] = VehicleLocationEntity(
        latitude: latitud,
        longitude: longitud,
        placa: placa,
        timestamp: DateTime.now(),
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
      for (final routeId in _selectedRoutes) {
        _webSocketService.subscribeToRoute(routeId);
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
    _selectedRoutes.add(event.routeId);

    if (_webSocketService.isConnected) {
      _webSocketService.subscribeToRoute(event.routeId);
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
    _selectedRoutes.remove(event.routeId);
    _webSocketService.unsubscribeFromRoute(event.routeId);

    _vehicleLocations.removeWhere(
      (key, value) => key.startsWith(event.routeId.split('/').last),
    );

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
    final previousRoutes = Set<String>.from(_selectedRoutes);
    final newRoutes = Set<String>.from(event.routeIds);

    final routesToAdd = newRoutes.difference(previousRoutes);
    final routesToRemove = previousRoutes.difference(newRoutes);

    if (!_webSocketService.isConnected && newRoutes.isNotEmpty) {
      try {
        await _webSocketService.connect();
      } catch (e) {
        emit(VehicleLocationError(message: e.toString()));
        return;
      }
    }

    for (final routeId in routesToAdd) {
      _selectedRoutes.add(routeId);
      if (_webSocketService.isConnected) {
        _webSocketService.subscribeToRoute(routeId);
      }
    }

    for (final routeId in routesToRemove) {
      _selectedRoutes.remove(routeId);
      _webSocketService.unsubscribeFromRoute(routeId);
    }

    final routePrefixes = newRoutes.map((r) => r.split('/').last).toSet();
    _vehicleLocations.removeWhere((key, value) {
      final keyPrefix = key.replaceAll(RegExp(r'[A-Z\-0-9]*$'), '');
      return !routePrefixes.any((prefix) => key.startsWith(prefix));
    });

    if (_selectedRoutes.isEmpty) {
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
