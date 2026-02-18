import 'package:flutter/material.dart';
import 'package:cliente/domain/entities/vehicle_location_entity.dart';

abstract class AbstractMapWidget extends StatefulWidget {
  final double userLatitude;
  final double userLongitude;
  final List<VehicleLocationEntity> vehicleLocations;
  final bool followUserLocation;
  final int recenterTrigger;
  final VoidCallback onMapInteraction;

  const AbstractMapWidget({
    required this.userLatitude,
    required this.userLongitude,
    required this.vehicleLocations,
    required this.followUserLocation,
    required this.recenterTrigger,
    required this.onMapInteraction,
    Key? key,
  }) : super(key: key);
}
