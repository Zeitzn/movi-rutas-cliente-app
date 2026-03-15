import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cliente/core/constants/map_constants.dart';
import 'package:cliente/core/errors/exceptions.dart';
import 'package:cliente/core/permissions/location_permission_service.dart';
import 'package:cliente/presentation/bloc/user_location/user_location_event.dart';
import 'package:cliente/presentation/bloc/user_location/user_location_state.dart';

class UserLocationBloc extends Bloc<UserLocationEvent, UserLocationState> {
  final LocationPermissionService locationPermissionService;

  UserLocationBloc({required this.locationPermissionService})
    : super(const UserLocationInitial()) {
    on<RequestPermissionsEvent>(_onRequestPermissions);
    on<UpdateUserLocationEvent>(_onUpdateUserLocation);
    on<StartListeningLocationEvent>(_onStartListeningLocation);
    on<EnableLocationServicesEvent>(_onEnableLocationServices);
  }

  Future<void> _onRequestPermissions(
    RequestPermissionsEvent event,
    Emitter<UserLocationState> emit,
  ) async {
    try {
      emit(const UserLocationLoading());

      final hasPermission = await locationPermissionService
          .requestLocationPermission();

      if (!hasPermission) {
        emit(const UserLocationPermissionDenied());
        return;
      }

      final isServiceEnabled = await locationPermissionService
          .isLocationEnabled();

      if (!isServiceEnabled) {
        emit(const UserLocationServiceDisabled());
        return;
      }

      final position = await locationPermissionService.getCurrentLocation();

      emit(
        UserLocationUpdated(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      add(const StartListeningLocationEvent());
    } on LocationPermissionException catch (e) {
      emit(_mapPermissionExceptionToState(e));
    } catch (e) {
      emit(UserLocationError(message: e.toString()));
    }
  }

  Future<void> _onUpdateUserLocation(
    UpdateUserLocationEvent event,
    Emitter<UserLocationState> emit,
  ) async {
    emit(
      UserLocationUpdated(latitude: event.latitude, longitude: event.longitude),
    );
  }

  Future<void> _onStartListeningLocation(
    StartListeningLocationEvent event,
    Emitter<UserLocationState> emit,
  ) async {
    try {
      final locationStream = locationPermissionService.getLocationStream(
        updateInterval: const Duration(seconds: 2),
        distanceFilter: 5,
      );

      await emit.forEach(
        locationStream,
        onData: (position) {
          return UserLocationUpdated(
            latitude: position.latitude,
            longitude: position.longitude,
          );
        },
        onError: (error, stackTrace) {
          if (error is LocationPermissionException) {
            return _mapPermissionExceptionToState(error);
          }
          return UserLocationError(message: error.toString());
        },
      );
    } on LocationPermissionException catch (e) {
      emit(_mapPermissionExceptionToState(e));
    } catch (e) {
      emit(UserLocationError(message: e.toString()));
    }
  }

  Future<void> _onEnableLocationServices(
    EnableLocationServicesEvent event,
    Emitter<UserLocationState> emit,
  ) async {
    try {
      emit(const UserLocationLoading());

      await locationPermissionService.enableLocationService();

      final isServiceEnabled = await locationPermissionService
          .isLocationEnabled();

      if (isServiceEnabled) {
        add(const RequestPermissionsEvent());
        return;
      }

      emit(const UserLocationServiceDisabled());
    } on LocationPermissionException catch (e) {
      emit(_mapPermissionExceptionToState(e));
    } catch (e) {
      emit(UserLocationError(message: e.toString()));
    }
  }

  UserLocationState _mapPermissionExceptionToState(
    LocationPermissionException exception,
  ) {
    switch (exception.type) {
      case LocationPermissionErrorType.permissionDenied:
        return const UserLocationPermissionDenied();
      case LocationPermissionErrorType.serviceDisabled:
        return const UserLocationServiceDisabled();
      case LocationPermissionErrorType.unknown:
        return UserLocationError(message: exception.message);
    }
  }
}
