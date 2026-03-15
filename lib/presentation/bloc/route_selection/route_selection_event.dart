import 'package:equatable/equatable.dart';
import 'package:cliente/domain/entities/route_entity.dart';

abstract class RouteSelectionEvent extends Equatable {
  const RouteSelectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadRoutesEvent extends RouteSelectionEvent {
  const LoadRoutesEvent();
}

class SelectRouteEvent extends RouteSelectionEvent {
  final RouteEntity route;

  const SelectRouteEvent({required this.route});

  @override
  List<Object?> get props => [route];
}

class SelectRoutesEvent extends RouteSelectionEvent {
  final List<RouteEntity> routes;

  const SelectRoutesEvent({required this.routes});

  @override
  List<Object?> get props => [routes];
}

class DeselectRouteEvent extends RouteSelectionEvent {
  const DeselectRouteEvent();
}
