import 'package:flutter/material.dart';
import 'package:cliente/domain/entities/vehicle_location_entity.dart';

abstract class AbstractMapWidget extends StatefulWidget {
  final double userLatitude;
  final double userLongitude;
  final List<VehicleLocationEntity> vehicleLocations;

  const AbstractMapWidget({
    required this.userLatitude,
    required this.userLongitude,
    required this.vehicleLocations,
    Key? key,
  }) : super(key: key);
}
