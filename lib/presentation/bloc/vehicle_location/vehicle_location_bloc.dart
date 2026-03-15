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

    _webSocketService.addListener(_onWebSocketMessageReceived);
  }

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
    await _webSocketService.disconnect();
    emit(
      VehicleLocationUpdated(
        locations: _vehicleLocations.values.toList(),
        isWebSocketConnected: false,
      ),
    );
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
