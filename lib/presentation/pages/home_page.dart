import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cliente/core/constants/map_constants.dart';
import 'package:cliente/domain/entities/vehicle_location_entity.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _onboardingSeenKey = 'onboarding_seen';

  @override
  void initState() {
    super.initState();
    context.read<RouteSelectionBloc>().add(const LoadRoutesEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeOnboarding();
    });
  }

  Future<void> _initializeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenStepper = prefs.getBool(_onboardingSeenKey) ?? false;

    if (!mounted) return;

    if (!hasSeenStepper) {
      await _showOnboardingSlides();
    } else {
      _requestLocationPermissions();
    }
  }

  Future<void> _markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, true);
  }

  void _requestLocationPermissions() {
    if (!mounted) return;
    context.read<UserLocationBloc>().add(const RequestPermissionsEvent());
  }

  Future<void> _showOnboardingSlides() async {
    if (!mounted) return;

    final pageController = PageController();
    int currentPage = 0;
    bool locationRequested = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final slideWidgets = [
              _buildOnboardingSlide(
                context: context,
                icon: Icons.my_location,
                title: 'Activa la ubicación',
                description:
                    'Enciende los servicios de ubicación y otorga permisos para que podamos localizarte con precisión.',
                extra: [
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!locationRequested) {
                          setStateDialog(() {
                            locationRequested = true;
                          });
                        }
                        _requestLocationPermissions();
                      },
                      child: const Text('Activar ubicación'),
                    ),
                  ),
                  if (locationRequested) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        SizedBox(
                          width: 220,
                          child: Text(
                            'Revisa la ventana del sistema y acepta para continuar.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              _buildOnboardingSlide(
                context: context,
                icon: Icons.search,
                title: 'Selecciona tu ruta',
                description:
                    'Utiliza el buscador para elegir la ruta que deseas rastrear. Podemos conectarnos a la ruta solo después de seleccionarla.',
              ),
              _buildOnboardingSlide(
                context: context,
                icon: Icons.map,
                title: 'Observa los vehículos',
                description:
                    'Una vez conectados, verás en el mapa la ubicación en tiempo real de los buses y su movimiento.',
              ),
            ];

            final isLastPage = currentPage == slideWidgets.length - 1;
            final canGoNext = currentPage == 0 ? locationRequested : true;
            final dialogHeight = (MediaQuery.of(context).size.height * 0.6)
                .clamp(320.0, 480.0);
            final pagePhysics = currentPage == 0 && !locationRequested
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics();

            return AlertDialog(
              title: const Text('Cómo usar la app'),
              content: SizedBox(
                width: double.maxFinite,
                child: SizedBox(
                  height: dialogHeight,
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: pageController,
                          physics: pagePhysics,
                          onPageChanged: (index) {
                            setStateDialog(() {
                              currentPage = index;
                            });
                          },
                          children: slideWidgets,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(slideWidgets.length, (index) {
                          final isActive = currentPage == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: isActive ? 24 : 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                if (currentPage > 0)
                  TextButton(
                    onPressed: () {
                      pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Anterior'),
                  ),
                ElevatedButton(
                  onPressed: canGoNext
                      ? () async {
                          if (isLastPage) {
                            await _markOnboardingSeen();
                            if (!mounted) return;
                            Navigator.of(dialogContext).pop();
                            _requestLocationPermissions();
                          } else {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        }
                      : null,
                  child: Text(isLastPage ? 'Entendido' : 'Siguiente'),
                ),
              ],
            );
          },
        );
      },
    );

    pageController.dispose();
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

  Widget _buildOnboardingSlide({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    List<Widget> extra = const [],
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            ...extra,
          ],
        ),
      ),
    );
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
