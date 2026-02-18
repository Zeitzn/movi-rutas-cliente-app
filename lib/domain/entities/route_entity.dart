import 'package:equatable/equatable.dart';

class RouteEntity extends Equatable {
  final String id;
  final String name;
  final String websocketUrl;

  const RouteEntity({
    required this.id,
    required this.name,
    required this.websocketUrl,
  });

  @override
  List<Object?> get props => [id, name, websocketUrl];
}
