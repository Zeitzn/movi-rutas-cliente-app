import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cliente/domain/entities/vehicle_location_entity.dart';
import 'package:cliente/presentation/widgets/map/abstract_map_widget.dart';
import 'package:cliente/core/constants/map_constants.dart';

class GoogleMapWidget extends AbstractMapWidget {
  const GoogleMapWidget({
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
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? _controller;
  late Set<Marker> _markers;
  BitmapDescriptor? _busIcon;

  @override
  void initState() {
    super.initState();
    _updateMarkers();
    _loadBusIcon();
  }

  Future<void> _loadBusIcon() async {
    try {
      _busIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/bus.png',
      );
    } catch (e) {
      _busIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(GoogleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLatitude != widget.userLatitude ||
        oldWidget.userLongitude != widget.userLongitude ||
        oldWidget.vehicleLocations != widget.vehicleLocations) {
      _updateMarkers();
    }

    final shouldRecentre =
        widget.followUserLocation &&
        (_controller != null) &&
        (oldWidget.userLatitude != widget.userLatitude ||
            oldWidget.userLongitude != widget.userLongitude ||
            oldWidget.recenterTrigger != widget.recenterTrigger);

    if (shouldRecentre) {
      _animateToUser();
    }
  }

  void _updateMarkers() {
    _markers = {};

    _markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(widget.userLatitude, widget.userLongitude),
        infoWindow: const InfoWindow(title: 'Tu ubicación'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    for (int i = 0; i < widget.vehicleLocations.length; i++) {
      final location = widget.vehicleLocations[i];
      _markers.add(
        Marker(
          markerId: MarkerId('vehicle_${location.placa}_$i'),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: 'Bus: ${location.placa}',
            snippet:
                'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}',
          ),
          icon:
              _busIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }
  }

  void _animateToUser() async {
    final currentZoom =
        await _controller?.getZoomLevel() ?? MapConstants.initialZoom;
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(widget.userLatitude, widget.userLongitude),
          zoom: currentZoom,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.userLatitude, widget.userLongitude),
        zoom: MapConstants.initialZoom,
      ),
      onMapCreated: (controller) {
        _controller = controller;
        if (widget.followUserLocation) {
          _animateToUser();
        }
      },
      onCameraMoveStarted: widget.onMapInteraction,
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }
}
