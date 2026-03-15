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
  final Set<String> _selectedRouteIds = {};

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

  void _confirmRouteSelection(Set<String> selectedRouteIds) {
    if (selectedRouteIds.isEmpty) {
      context.read<RouteSelectionBloc>().add(const DeselectRouteEvent());
      context.read<VehicleLocationBloc>().add(
        const StopWebSocketListeningEvent(),
      );
      context.read<VehicleLocationBloc>().add(const ClearLocationsEvent());
      setState(() {
        _selectedRouteIds.clear();
      });
    } else {
      final routes =
          (context.read<RouteSelectionBloc>().state as RouteSelectionLoaded)
              .routes
              .where((r) => selectedRouteIds.contains(r.id))
              .toList();

      if (routes.isNotEmpty) {
        context.read<RouteSelectionBloc>().add(
          SelectRoutesEvent(routes: routes),
        );
        context.read<VehicleLocationBloc>().add(
          UpdateSelectedRoutesEvent(routeIds: selectedRouteIds.toList()),
        );
        setState(() {
          _selectedRouteIds.clear();
          _selectedRouteIds.addAll(selectedRouteIds);
        });
      }
    }
  }

  void _handleRouteSelection(dynamic selectedRoute) {
    if (selectedRoute == null) {
      context.read<RouteSelectionBloc>().add(const DeselectRouteEvent());
      context.read<VehicleLocationBloc>().add(
        const StopWebSocketListeningEvent(),
      );
      context.read<VehicleLocationBloc>().add(const ClearLocationsEvent());
      setState(() {
        _selectedRouteIds.clear();
      });
    }
  }

  void _showRouteDropdown(BuildContext context, RouteSelectionLoaded state) {
    final tempSelectedRoutes = Set<String>.from(
      state.selectedRoutes.map((r) => r.id),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Selecciona rutas',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(bottomSheetContext);
                                _confirmRouteSelection(tempSelectedRoutes);
                              },
                              child: Text(
                                'Confirmar (${tempSelectedRoutes.length})',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Selecciona una o más rutas para ver buses en tiempo real',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          shrinkWrap: true,
                          itemCount: state.routes.length,
                          itemBuilder: (context, index) {
                            final route = state.routes[index];
                            final isSelected = tempSelectedRoutes.contains(
                              route.id,
                            );

                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) {
                                setModalState(() {
                                  if (value == true) {
                                    tempSelectedRoutes.add(route.id);
                                  } else {
                                    tempSelectedRoutes.remove(route.id);
                                  }
                                });
                              },
                              title: Text(route.name),
                              subtitle: Text(
                                route.id,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                              secondary: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.1)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.directions_bus,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade400,
                                  size: 20,
                                ),
                              ),
                              activeColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              checkColor: Colors.white,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
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
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildRouteSelectorCard(context),
            const SizedBox(height: 16),
            _buildMapSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.directions_bus_rounded,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enrutados',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Monitorea tus rutas en tiempo real',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSelectorCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocBuilder<RouteSelectionBloc, RouteSelectionState>(
        builder: (context, state) {
          if (state is RouteSelectionLoaded) {
            final hasSelectedRoutes = state.selectedRoutes.isNotEmpty;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showRouteDropdown(context, state),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      hasSelectedRoutes ? 12 : 16,
                      16,
                      hasSelectedRoutes ? 12 : 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            hasSelectedRoutes
                                ? Icons.check_circle
                                : Icons.search,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: hasSelectedRoutes
                                ? Column(
                                    key: const ValueKey('collapsed'),
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${state.selectedRoutes.length} ruta(s) seleccionada(s)',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade500,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Wrap(
                                        spacing: 4,
                                        runSpacing: 2,
                                        children: state.selectedRoutes
                                            .take(2)
                                            .map(
                                              (r) => Text(
                                                r.name,
                                                style: textTheme.titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                      if (state.selectedRoutes.length > 2)
                                        Text(
                                          '+${state.selectedRoutes.length - 2} más',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.primary,
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  )
                                : Column(
                                    key: const ValueKey('expanded'),
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selecciona tu ruta',
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Elige una ruta para ver buses en tiempo real',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        if (hasSelectedRoutes)
                          GestureDetector(
                            onTap: () {
                              context.read<RouteSelectionBloc>().add(
                                const DeselectRouteEvent(),
                              );
                              context.read<VehicleLocationBloc>().add(
                                const StopWebSocketListeningEvent(),
                              );
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () => _showRouteDropdown(context, state),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else if (state is RouteSelectionError) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade400),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Error al cargar rutas',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<RouteSelectionBloc>().add(
                        const LoadRoutesEvent(),
                      );
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Cargando rutas...',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapSection(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
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
                        final hasSelectedRoutes =
                            state is RouteSelectionLoaded &&
                            state.selectedRoutes.isNotEmpty;

                        return StatusMessageWidget(
                          message: 'Selecciona la ruta que estás esperando',
                          show: !hasSelectedRoutes,
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
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.shade600
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Conectado',
                                        style: TextStyle(
                                          color: Colors.white,
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        elevation: 4,
        shadowColor: Colors.black26,
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
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: enabled
                  ? (isActive ? colorScheme.primary : Colors.white)
                  : Colors.white.withOpacity(0.5),
            ),
            child: Icon(
              Icons.my_location,
              color: enabled
                  ? (isActive ? Colors.white : colorScheme.primary)
                  : Colors.grey,
              size: 24,
            ),
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
