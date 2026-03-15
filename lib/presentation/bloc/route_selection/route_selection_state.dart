import 'package:equatable/equatable.dart';
import 'package:cliente/domain/entities/route_entity.dart';

abstract class RouteSelectionState extends Equatable {
  const RouteSelectionState();

  @override
  List<Object?> get props => [];
}

class RouteSelectionInitial extends RouteSelectionState {
  const RouteSelectionInitial();
}

class RouteSelectionLoading extends RouteSelectionState {
  const RouteSelectionLoading();
}

class RouteSelectionLoaded extends RouteSelectionState {
  final List<RouteEntity> routes;
  final RouteEntity? selectedRoute;
  final List<RouteEntity> selectedRoutes;

  const RouteSelectionLoaded({
    required this.routes,
    this.selectedRoute,
    this.selectedRoutes = const [],
  });

  bool get hasSelectedRoutes => selectedRoutes.isNotEmpty;

  @override
  List<Object?> get props => [routes, selectedRoute, selectedRoutes];
}

class RouteSelectionError extends RouteSelectionState {
  final String message;

  const RouteSelectionError({required this.message});

  @override
  List<Object?> get props => [message];
}
