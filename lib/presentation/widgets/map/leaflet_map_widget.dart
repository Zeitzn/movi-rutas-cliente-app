import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cliente/domain/entities/vehicle_location_entity.dart';
import 'package:cliente/presentation/widgets/map/abstract_map_widget.dart';
import 'package:cliente/core/constants/map_constants.dart';

class LeafletMapWidget extends AbstractMapWidget {
  const LeafletMapWidget({
    required double userLatitude,
    required double userLongitude,
    required List<VehicleLocationEntity> vehicleLocations,
    required bool followUserLocation,
    required int recenterTrigger,
    required VoidCallback onMapInteraction,
    Key? key,
  }) : super(
         userLatitude: userLatitude,
         userLongitude: userLongitude,
         vehicleLocations: vehicleLocations,
         followUserLocation: followUserLocation,
         recenterTrigger: recenterTrigger,
         onMapInteraction: onMapInteraction,
         key: key,
       );

  @override
  State<LeafletMapWidget> createState() => _LeafletMapWidgetState();
}

class _LeafletMapWidgetState extends State<LeafletMapWidget> {
  late MapController _mapController;
  late List<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _updateMarkers();
  }

  @override
  void didUpdateWidget(LeafletMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLatitude != widget.userLatitude ||
        oldWidget.userLongitude != widget.userLongitude ||
        oldWidget.vehicleLocations != widget.vehicleLocations) {
      _updateMarkers();
    }

    final shouldRecentre =
        widget.followUserLocation &&
        (oldWidget.userLatitude != widget.userLatitude ||
            oldWidget.userLongitude != widget.userLongitude ||
            oldWidget.recenterTrigger != widget.recenterTrigger);

    if (shouldRecentre) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(
          LatLng(widget.userLatitude, widget.userLongitude),
          MapConstants.initialZoom,
        );
      });
    }
  }

  void _updateMarkers() {
    _markers = [];

    // Marcador del usuario
    _markers.add(
      Marker(
        point: LatLng(widget.userLatitude, widget.userLongitude),
        width: 40.0,
        height: 40.0,
        child: Tooltip(
          message: 'Tu ubicación',
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );

    // Marcadores de vehículos
    for (int i = 0; i < widget.vehicleLocations.length; i++) {
      final location = widget.vehicleLocations[i];
      _markers.add(
        Marker(
          point: LatLng(location.latitude, location.longitude),
          width: 40.0,
          height: 40.0,
          child: Tooltip(
            message: 'Placa: ${location.placa}',
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.directions_car,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(widget.userLatitude, widget.userLongitude),
        initialZoom: MapConstants.initialZoom,
        maxZoom: MapConstants.maxZoom,
        minZoom: MapConstants.minZoom,
        onPointerDown: (event, point) => widget.onMapInteraction(),
        onMapEvent: (event) {
          if (event is MapEventMoveStart) {
            widget.onMapInteraction();
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.movi.rutas',
        ),
        MarkerLayer(markers: _markers),
      ],
    );
  }
}
