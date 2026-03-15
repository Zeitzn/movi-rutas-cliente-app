import 'package:cliente/domain/entities/route_entity.dart';

class RouteModel {
  final String id;
  final String name;
  final String code;
  final int mainColor;
  final int secondaryColor;

  RouteModel({
    required this.id,
    required this.name,
    required this.code,
    required this.mainColor,
    required this.secondaryColor,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      mainColor: json['main_color'] ?? 0xFFFF5722,
      secondaryColor: json['secondary_color'] ?? 0xFFFF8A65,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'main_color': mainColor,
      'secondary_color': secondaryColor,
    };
  }

  RouteEntity toEntity() {
    return RouteEntity(
      id: id,
      name: name,
      code: code,
      mainColor: mainColor,
      secondaryColor: secondaryColor,
    );
  }
}
