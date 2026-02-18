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

class LocationPermissionException implements Exception {
  final String message;

  LocationPermissionException({required this.message});

  @override
  String toString() => 'LocationPermissionException: $message';
}

class WebSocketException implements Exception {
  final String message;

  WebSocketException({required this.message});

  @override
  String toString() => 'WebSocketException: $message';
}
