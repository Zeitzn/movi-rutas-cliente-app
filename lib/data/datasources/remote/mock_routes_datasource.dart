import 'package:cliente/data/models/route_model.dart';

abstract class MockRoutesDataSource {
  Future<List<RouteModel>> getRoutes();
}

class MockRoutesDataSourceImpl implements MockRoutesDataSource {
  @override
  Future<List<RouteModel>> getRoutes() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final mockData = [
      {
        'id': 'route_001',
        'name': 'Ruta Centro-Norte',
        'code': '001',
        // 'websocket_url': 'ws://192.168.1.100:3000/ws/routes/route_001',
        'main_color': 0xFFF81302,
        'secondary_color': 0xFF0043FC
      },
      {
        'id': 'route_002',
        'name': 'Ruta Sureste',
        'code': '002',
        // 'websocket_url': 'ws://192.168.1.100:3000/ws/routes/route_002',
        'main_color': 0xFF4CAF50,
        'secondary_color': 0xFF81C784,
      },
      {
        'id': 'route_003',
        'name': 'Ruta Occidente',
        'code': '003',
        // 'websocket_url': 'ws://192.168.1.100:3000/ws/routes/route_003',
        'main_color': 0xFFFF9800,
        'secondary_color': 0xFFFFB74D,
      },
      {
        'id': 'route_004',
        'name': 'Ruta Oriente',
        'code': '004',
        // 'websocket_url': 'ws://192.168.1.100:3000/ws/routes/route_004',
        'main_color': 0xFF9C27B0,
        'secondary_color': 0xFFBA68C8,
      },
      {
        'id': 'route_005',
        'name': 'Ruta Norte',
        'code': '005',
        // 'websocket_url': 'ws://192.168.1.100:3000/ws/routes/route_005',
        'main_color': 0xFFF44336,
        'secondary_color': 0xFFE57373,
      },
      {
        'id': 'route_006',
        'name': 'Ruta Sur',
        'code': '006',
        // 'websocket_url': 'ws://192.168.1.100:3000/ws/routes/route_006',
        'main_color': 0xFF00BCD4,
        'secondary_color': 0xFF4DD0E1,
      },
    ];

    return mockData
        .map((item) => RouteModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
