import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cliente/domain/repositories/vehicle_location_repository.dart';
import 'package:cliente/presentation/bloc/vehicle_location/vehicle_location_event.dart';
import 'package:cliente/presentation/bloc/vehicle_location/vehicle_location_state.dart';

class VehicleLocationBloc
    extends Bloc<VehicleLocationEvent, VehicleLocationState> {
  final VehicleLocationRepository repository;

  VehicleLocationBloc({required this.repository})
    : super(const VehicleLocationInitial()) {
    on<ListenVehicleLocationsEvent>(_onListenVehicleLocations);
    on<UpdateVehicleLocationEvent>(_onUpdateVehicleLocation);
    on<ClearLocationsEvent>(_onClearLocations);
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
          (locations) => VehicleLocationUpdated(locations: locations),
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
    emit(VehicleLocationUpdated(locations: event.locations));
  }

  Future<void> _onClearLocations(
    ClearLocationsEvent event,
    Emitter<VehicleLocationState> emit,
  ) async {
    emit(const VehicleLocationInitial());
  }
}
