import 'dart:convert';
import 'package:cliente/core/network/websocket_service.dart';
import 'package:cliente/data/models/vehicle_location_model.dart';
import 'package:cliente/core/errors/exceptions.dart';

abstract class WebSocketDataSource {
  Future<void> connect(String url);
  void disconnect();
  Stream<List<VehicleLocationModel>> listenVehicleLocations();
}

class WebSocketDataSourceImpl implements WebSocketDataSource {
  final WebSocketService webSocketService;
  late Stream<List<VehicleLocationModel>> _locationStream;

  WebSocketDataSourceImpl({required this.webSocketService});

  @override
  Future<void> connect(String url) async {
    await webSocketService.connect(url);
    _initializeLocationStream();
  }

  @override
  void disconnect() {
    webSocketService.disconnect();
  }

  @override
  Stream<List<VehicleLocationModel>> listenVehicleLocations() {
    return _locationStream;
  }

  void _initializeLocationStream() {
    _locationStream = webSocketService.stream
        .map((message) {
          try {
            if (message is String) {
              final jsonData = jsonDecode(message);

              if (jsonData is Map<String, dynamic>) {
                return [VehicleLocationModel.fromJson(jsonData)];
              }

              if (jsonData is List) {
                return (jsonData as List)
                    .map(
                      (item) => VehicleLocationModel.fromJson(
                        item as Map<String, dynamic>,
                      ),
                    )
                    .toList();
              }
            }

            return [];
          } catch (e) {
            throw WebSocketException(
              message: 'Error parsing message: ${e.toString()}',
            );
          }
        })
        .cast<List<VehicleLocationModel>>()
        .handleError((error) {
          throw WebSocketException(
            message: 'WebSocket error: ${error.toString()}',
          );
        });
  }
}
