class ServerException implements Exception {
  final String message;

  ServerException({required this.message});

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

enum LocationPermissionErrorType { permissionDenied, serviceDisabled, unknown }

class LocationPermissionException implements Exception {
  final String message;
  final LocationPermissionErrorType type;

  LocationPermissionException({
    required this.message,
    this.type = LocationPermissionErrorType.unknown,
  });

  @override
  String toString() => 'LocationPermissionException: $message';
}

class WebSocketException implements Exception {
  final String message;

  WebSocketException({required this.message});

  @override
  String toString() => 'WebSocketException: $message';
}
