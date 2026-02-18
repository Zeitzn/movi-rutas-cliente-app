import 'package:geolocator/geolocator.dart';
import 'package:cliente/core/errors/exceptions.dart';

abstract class LocationPermissionService {
  Future<bool> requestLocationPermission();
  Future<bool> isLocationEnabled();
  Future<Position> getCurrentLocation();
  Stream<Position> getLocationStream({
    required Duration updateInterval,
    required int distanceFilter,
  });
}

class LocationPermissionServiceImpl implements LocationPermissionService {
  @override
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw LocationPermissionException(
          message: 'Location permission denied',
        );
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      throw LocationPermissionException(
        message: 'Failed to request location permission: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> isLocationEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      throw LocationPermissionException(
        message: 'Failed to check location service: ${e.toString()}',
      );
    }
  }

  @override
  Future<Position> getCurrentLocation() async {
    try {
      final isEnabled = await isLocationEnabled();
      if (!isEnabled) {
        throw LocationPermissionException(
          message: 'Location service is disabled',
        );
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw LocationPermissionException(
          message: 'Location permission not granted',
        );
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (e) {
      throw LocationPermissionException(
        message: 'Failed to get current location: ${e.toString()}',
      );
    }
  }

  @override
  Stream<Position> getLocationStream({
    required Duration updateInterval,
    required int distanceFilter,
  }) {
    return Geolocator.getPositionStream();
  }
}
