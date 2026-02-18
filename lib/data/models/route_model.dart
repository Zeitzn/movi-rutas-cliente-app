import 'package:cliente/domain/entities/route_entity.dart';

class RouteModel {
  final String id;
  final String name;
  final String websocketUrl;

  RouteModel({
    required this.id,
    required this.name,
    required this.websocketUrl,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      websocketUrl: json['websocket_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'websocket_url': websocketUrl};
  }

  RouteEntity toEntity() {
    return RouteEntity(id: id, name: name, websocketUrl: websocketUrl);
  }
}
