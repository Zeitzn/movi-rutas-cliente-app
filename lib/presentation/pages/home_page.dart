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
  bool _followUserLocation = true;
  int _recenterTrigger = 0;

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
    setState(() {
      _followUserLocation = true;
    });
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
      context.read<VehicleLocationBloc>().add(
        const StopWebSocketListeningEvent(),
      );
      context.read<VehicleLocationBloc>().add(const ClearLocationsEvent());
    } else {
      // Seleccionar ruta
      context.read<RouteSelectionBloc>().add(
        SelectRouteEvent(route: selectedRoute),
      );
      context.read<VehicleLocationBloc>().add(
        const StartWebSocketListeningEvent(),
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
        followUserLocation: _followUserLocation,
        recenterTrigger: _recenterTrigger,
        onMapInteraction: _handleMapInteraction,
      );
    } else {
      return LeafletMapWidget(
        userLatitude: userLat,
        userLongitude: userLng,
        vehicleLocations: vehicles,
        followUserLocation: _followUserLocation,
        recenterTrigger: _recenterTrigger,
        onMapInteraction: _handleMapInteraction,
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.secondary.withOpacity(0.9),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.2),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Icon(icon, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.92),
                height: 1.5,
              ),
            ),
            ...extra,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoMessage({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    List<Widget> actions = const [],
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.08),
              ),
              child: Icon(icon, size: 40, color: colorScheme.primary),
            ),
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
              style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            if (actions.isNotEmpty) ...[const SizedBox(height: 18), ...actions],
          ],
        ),
      ),
    );
  }

  Widget _buildEnableLocationPrompt(BuildContext context) {
    return _buildInfoMessage(
      context: context,
      icon: Icons.location_searching_rounded,
      title: 'Activa los servicios de ubicación',
      description:
          'Para centrar el mapa en ti necesitamos que el GPS del dispositivo esté habilitado.',
      actions: [
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
        Text(
          'Intentaremos activarla automáticamente o te dirigiremos a la configuración del sistema.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.12),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildRouteSelectorCard(context),
              const SizedBox(height: 16),
              _buildMapSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withOpacity(0.78),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.25),
              blurRadius: 26,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.directions_bus_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enrutados',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Planifica y monitorea tus rutas en tiempo real.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSelectorCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocBuilder<RouteSelectionBloc, RouteSelectionState>(
        builder: (context, state) {
          if (state is RouteSelectionLoaded) {
            final isCollapsed = state.selectedRoute != null;

            return Card(
              margin: EdgeInsets.zero,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: EdgeInsets.fromLTRB(20, isCollapsed ? 12 : 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: isCollapsed
                          ? const SizedBox.shrink(key: ValueKey('collapsed'))
                          : Column(
                              key: const ValueKey('expanded'),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¿A qué ruta quieres hacer seguimiento hoy?',
                                  style: textTheme.titleMedium,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Selecciona una ruta para conectarte al rastreo en vivo.',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                    ),
                    RouteSelectorWidget(
                      routes: state.routes,
                      selectedRoute: state.selectedRoute,
                      onRouteSelected: _handleRouteSelection,
                      isLoading: false,
                    ),
                  ],
                ),
              ),
            );
          } else if (state is RouteSelectionError) {
            return Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No pudimos cargar las rutas (${state.message}).',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        context.read<RouteSelectionBloc>().add(
                          const LoadRoutesEvent(),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Intentar de nuevo'),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                BlocBuilder<UserLocationBloc, UserLocationState>(
                  builder: (context, userLocationState) {
                    double userLat = MapConstants.defaultLatitude;
                    double userLng = MapConstants.defaultLongitude;
                    bool hasUserLocation = false;

                    if (userLocationState is UserLocationUpdated) {
                      userLat = userLocationState.latitude;
                      userLng = userLocationState.longitude;
                      hasUserLocation = true;
                    } else if (userLocationState is UserLocationError) {
                      return _buildInfoMessage(
                        context: context,
                        icon: Icons.error_outline,
                        title: 'No pudimos ubicarte',
                        description: userLocationState.message,
                        actions: [
                          ElevatedButton(
                            onPressed: _requestLocationPermissions,
                            child: const Text('Intentar nuevamente'),
                          ),
                        ],
                      );
                    } else if (userLocationState
                        is UserLocationPermissionDenied) {
                      return _buildInfoMessage(
                        context: context,
                        icon: Icons.privacy_tip_outlined,
                        title: 'Permiso de ubicación denegado',
                        description:
                            'Activa los permisos de ubicación para rastrear tu posición actual.',
                        actions: [
                          ElevatedButton(
                            onPressed: _requestLocationPermissions,
                            child: const Text('Conceder permisos'),
                          ),
                        ],
                      );
                    } else if (userLocationState
                        is UserLocationServiceDisabled) {
                      return _buildEnableLocationPrompt(context);
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

                        return Stack(
                          children: [
                            _buildMapWidget(userLat, userLng, vehicles),
                            Positioned(
                              right: 16,
                              bottom: 100,
                              child: _buildCurrentLocationButton(
                                context,
                                enabled: hasUserLocation,
                                isActive: _followUserLocation,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                ),
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child:
                        BlocBuilder<VehicleLocationBloc, VehicleLocationState>(
                          builder: (context, state) {
                            final isConnected =
                                state is VehicleLocationUpdated &&
                                state.isWebSocketConnected;

                            return AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: isConnected ? 1.0 : 0.0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.green.shade400,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.wifi,
                                        size: 16,
                                        color: Colors.green.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Conectado',
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLocationButton(
    BuildContext context, {
    required bool enabled,
    required bool isActive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Centrar en mi ubicación',
      child: InkWell(
        onTap: enabled
            ? () {
                setState(() {
                  _followUserLocation = true;
                  _recenterTrigger++;
                });
              }
            : null,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled
                ? (isActive ? colorScheme.primary : Colors.white)
                : Colors.white.withOpacity(0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.my_location,
            color: enabled
                ? (isActive ? Colors.white : colorScheme.primary)
                : Colors.grey,
          ),
        ),
      ),
    );
  }

  void _handleMapInteraction() {
    if (_followUserLocation) {
      setState(() {
        _followUserLocation = false;
      });
    }
  }
}
