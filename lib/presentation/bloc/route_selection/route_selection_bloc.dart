import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cliente/core/usecases/usecase.dart';
import 'package:cliente/domain/usecases/get_routes_usecase.dart';
import 'package:cliente/presentation/bloc/route_selection/route_selection_event.dart';
import 'package:cliente/presentation/bloc/route_selection/route_selection_state.dart';

class RouteSelectionBloc
    extends Bloc<RouteSelectionEvent, RouteSelectionState> {
  final GetRoutesUseCase getRoutesUseCase;

  RouteSelectionBloc({required this.getRoutesUseCase})
    : super(const RouteSelectionInitial()) {
    on<LoadRoutesEvent>(_onLoadRoutes);
    on<SelectRouteEvent>(_onSelectRoute);
    on<DeselectRouteEvent>(_onDeselectRoute);
  }

  Future<void> _onLoadRoutes(
    LoadRoutesEvent event,
    Emitter<RouteSelectionState> emit,
  ) async {
    emit(const RouteSelectionLoading());

    final result = await getRoutesUseCase(NoParams());

    result.fold(
      (failure) => emit(RouteSelectionError(message: failure.toString())),
      (routes) => emit(RouteSelectionLoaded(routes: routes)),
    );
  }

  Future<void> _onSelectRoute(
    SelectRouteEvent event,
    Emitter<RouteSelectionState> emit,
  ) async {
    if (state is RouteSelectionLoaded) {
      final currentState = state as RouteSelectionLoaded;
      emit(
        RouteSelectionLoaded(
          routes: currentState.routes,
          selectedRoute: event.route,
        ),
      );
    }
  }

  Future<void> _onDeselectRoute(
    DeselectRouteEvent event,
    Emitter<RouteSelectionState> emit,
  ) async {
    if (state is RouteSelectionLoaded) {
      final currentState = state as RouteSelectionLoaded;
      emit(
        RouteSelectionLoaded(routes: currentState.routes, selectedRoute: null),
      );
    }
  }
}
