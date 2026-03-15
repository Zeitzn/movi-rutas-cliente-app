import 'package:equatable/equatable.dart';

class RouteEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final int mainColor;
  final int secondaryColor;

  const RouteEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.mainColor,
    required this.secondaryColor,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    mainColor,
    secondaryColor,
  ];
}
