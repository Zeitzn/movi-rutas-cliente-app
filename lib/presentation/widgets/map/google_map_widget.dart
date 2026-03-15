import 'dart:ui' as ui;
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
  final Map<String, BitmapDescriptor> _coloredIcons = {};
  final Map<String, bool> _loadingIcons = {};

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  String _getIconKey(VehicleLocationEntity location) {
    return '${location.mainColor}_${location.secondaryColor}';
  }

  void _getMarkerIcon(VehicleLocationEntity location) async {
    final key = _getIconKey(location);
    if (_coloredIcons.containsKey(key) || _loadingIcons[key] == true) {
      return;
    }

    _loadingIcons[key] = true;

    final icon = await _createTwoToneMarkerIcon(
      location.mainColor,
      location.secondaryColor,
    );

    _loadingIcons[key] = false;
    _coloredIcons[key] = icon;

    if (mounted) {
      setState(() {});
    }
  }

  Future<BitmapDescriptor> _createTwoToneMarkerIcon(
    int mainColor,
    int secondaryColor,
  ) async {
    const double size = 48.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);
    final radius = size / 2 - 1;

    final mainPaint = Paint()
      ..color = Color(mainColor)
      ..style = PaintingStyle.fill;

    final secondaryPaint = Paint()
      ..color = Color(secondaryColor)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, mainPaint);

    final path = Path();
    path.moveTo(0, size / 2);
    path.lineTo(size, size / 2);
    path.lineTo(size, size);
    path.lineTo(0, size);
    path.close();
    canvas.drawPath(path, secondaryPaint);

    canvas.drawCircle(center, radius, borderPaint);

    canvas.drawCircle(Offset(size * 0.35, size * 0.35), size * 0.15, mainPaint);
    canvas.drawCircle(
      Offset(size * 0.65, size * 0.65),
      size * 0.12,
      secondaryPaint,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
    }

    return BitmapDescriptor.defaultMarkerWithHue(
      HSLColor.fromColor(Color(mainColor)).hue,
    );
  }

  BitmapDescriptor _getCachedIcon(VehicleLocationEntity location) {
    final key = _getIconKey(location);
    return _coloredIcons[key] ??
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
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

    for (final location in widget.vehicleLocations) {
      _getMarkerIcon(location);
    }

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
            snippet: location.routeCode.isNotEmpty
                ? 'Ruta: ${location.routeCode}'
                : 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}',
          ),
          icon: _getCachedIcon(location),
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
