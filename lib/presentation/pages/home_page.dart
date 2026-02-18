import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cliente/presentation/bloc/route_selection/route_selection_bloc.dart';
import 'package:cliente/presentation/bloc/route_selection/route_selection_event.dart';
import 'package:cliente/presentation/bloc/route_selection/route_selection_state.dart';
import 'package:cliente/presentation/bloc/user_location/user_location_bloc.dart';
import 'package:cliente/presentation/bloc/user_location/user_location_event.dart';
import 'package:cliente/presentation/bloc/user_location/user_location_state.dart';
import 'package:cliente/presentation/bloc/vehicle_location/vehicle_location_bloc.dart';
import 'package:cliente/presentation/bloc/vehicle_location/vehicle_location_event.dart';
import 'package:cliente/presentation/bloc/vehicle_location/vehicle_location_state.dart';
import 'package:cliente/presentation/bloc/websocket/websocket_bloc.dart';
import 'package:cliente/presentation/bloc/websocket/websocket_event.dart';
import 'package:cliente/presentation/utils/map_provider.dart';
import 'package:cliente/presentation/widgets/map/google_map_widget.dart';
import 'package:cliente/presentation/widgets/map/leaflet_map_widget.dart';
import 'package:cliente/presentation/widgets/route_selector/route_selector_widget.dart';
import 'package:cliente/presentation/widgets/status_message/status_message_widget.dart';
import 'package:cliente/core/constants/map_constants.dart';
import 'package:cliente/domain/entities/vehicle_location_entity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<UserLocationBloc>().add(const RequestPermissionsEvent());
    context.read<RouteSelectionBloc>().add(const LoadRoutesEvent());
  }

  void _handleRouteSelection(dynamic selectedRoute) {
    if (selectedRoute == null) {
      // Desseleccionar ruta
      context.read<RouteSelectionBloc>().add(const DeselectRouteEvent());
      context.read<WebSocketBloc>().add(const DisconnectWebSocketEvent());
      context.read<VehicleLocationBloc>().add(const ClearLocationsEvent());
    } else {
      // Seleccionar ruta
      context.read<RouteSelectionBloc>().add(
        SelectRouteEvent(route: selectedRoute),
      );
      context.read<WebSocketBloc>().add(
        ConnectWebSocketEvent(
          routeId: selectedRoute.id,
          websocketUrl: selectedRoute.websocketUrl,
        ),
      );
      context.read<VehicleLocationBloc>().add(
        ListenVehicleLocationsEvent(routeId: selectedRoute.id),
      );
    }
  }

  Widget _buildMapWidget(
    double userLat,
    double userLng,
    List<VehicleLocationEntity> vehicles,
  ) {
    if (MapProviderConfig.isGoogleMaps()) {
      return GoogleMapWidget(
        userLatitude: userLat,
        userLongitude: userLng,
        vehicleLocations: vehicles,
      );
    } else {
      return LeafletMapWidget(
        userLatitude: userLat,
        userLongitude: userLng,
        vehicleLocations: vehicles,
      );
    }
  }

  Widget _buildEnableLocationPrompt(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text(
            'Necesitamos que actives el servicio de ubicación para continuar.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<UserLocationBloc>().add(
                  const EnableLocationServicesEvent(),
                );
              },
              child: const Text('Activar ubicación'),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Intentaremos encenderla automáticamente o te llevaremos a la configuración.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rastreo de Rutas'), elevation: 0),
      body: Column(
        children: [
          BlocBuilder<RouteSelectionBloc, RouteSelectionState>(
            builder: (context, state) {
              if (state is RouteSelectionLoaded) {
                return RouteSelectorWidget(
                  routes: state.routes,
                  selectedRoute: state.selectedRoute,
                  onRouteSelected: _handleRouteSelection,
                  isLoading: false,
                );
              } else if (state is RouteSelectionLoading) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: const CircularProgressIndicator(),
                );
              } else if (state is RouteSelectionError) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              return Container(
                padding: const EdgeInsets.all(16.0),
                child: const CircularProgressIndicator(),
              );
            },
          ),
          Expanded(
            child: Stack(
              children: [
                BlocBuilder<UserLocationBloc, UserLocationState>(
                  builder: (context, userLocationState) {
                    double userLat = MapConstants.defaultLatitude;
                    double userLng = MapConstants.defaultLongitude;

                    if (userLocationState is UserLocationUpdated) {
                      userLat = userLocationState.latitude;
                      userLng = userLocationState.longitude;
                    } else if (userLocationState is UserLocationError) {
                      return Center(
                        child: Text(
                          'Error de ubicación: ${userLocationState.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (userLocationState
                        is UserLocationPermissionDenied) {
                      return const Center(
                        child: Text(
                          'Permiso de ubicación denegado',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (userLocationState
                        is UserLocationServiceDisabled) {
                      return Center(child: _buildEnableLocationPrompt(context));
                    }

                    return BlocBuilder<
                      VehicleLocationBloc,
                      VehicleLocationState
                    >(
                      builder: (context, vehicleLocationState) {
                        List<VehicleLocationEntity> vehicles = [];

                        if (vehicleLocationState is VehicleLocationUpdated) {
                          vehicles = vehicleLocationState.locations;
                        }

                        return _buildMapWidget(userLat, userLng, vehicles);
                      },
                    );
                  },
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: BlocBuilder<RouteSelectionBloc, RouteSelectionState>(
                    builder: (context, state) {
                      final hasSelectedRoute =
                          state is RouteSelectionLoaded &&
                          state.selectedRoute != null;

                      return StatusMessageWidget(
                        message: 'Selecciona la ruta que estás esperando',
                        show: !hasSelectedRoute,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
