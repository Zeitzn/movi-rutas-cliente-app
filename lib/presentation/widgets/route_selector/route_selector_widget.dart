import 'package:flutter/material.dart';
import 'package:cliente/domain/entities/route_entity.dart';

class RouteSelectorWidget extends StatelessWidget {
  final List<RouteEntity> routes;
  final RouteEntity? selectedRoute;
  final ValueChanged<RouteEntity?> onRouteSelected;
  final bool isLoading;

  const RouteSelectorWidget({
    required this.routes,
    required this.selectedRoute,
    required this.onRouteSelected,
    this.isLoading = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButton<RouteEntity?>(
        isExpanded: true,
        hint: const Text('Seleccionar ruta'),
        value: selectedRoute,
        onChanged: isLoading ? null : onRouteSelected,
        items: [
          const DropdownMenuItem<RouteEntity?>(
            value: null,
            child: Text('Seleccionar ruta'),
          ),
          ...routes.map((route) {
            return DropdownMenuItem<RouteEntity?>(
              value: route,
              child: Text(route.name),
            );
          }).toList(),
        ],
      ),
    );
  }
}
