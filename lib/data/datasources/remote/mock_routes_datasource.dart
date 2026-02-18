import 'package:cliente/data/models/route_model.dart';

abstract class MockRoutesDataSource {
  Future<List<RouteModel>> getRoutes();
}

class MockRoutesDataSourceImpl implements MockRoutesDataSource {
  @override
  Future<List<RouteModel>> getRoutes() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));

    final mockData = [
      {
        'id': 'route_001',
        'name': 'Ruta Centro-Norte',
        'websocket_url': 'ws://192.168.1.100:3000/ws/routes/route_001',
      },
      {
        'id': 'route_002',
        'name': 'Ruta Sureste',
        'websocket_url': 'ws://192.168.1.100:3000/ws/routes/route_002',
      },
      {
        'id': 'route_003',
        'name': 'Ruta Occidente',
        'websocket_url': 'ws://192.168.1.100:3000/ws/routes/route_003',
      },
      {
        'id': 'route_004',
        'name': 'Ruta Oriente',
        'websocket_url': 'ws://192.168.1.100:3000/ws/routes/route_004',
      },
    ];

    return mockData
        .map((item) => RouteModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
