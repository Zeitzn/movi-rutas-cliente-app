import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cliente/config/service_locator.dart';
import 'package:cliente/presentation/bloc/route_selection/route_selection_bloc.dart';
import 'package:cliente/presentation/bloc/user_location/user_location_bloc.dart';
import 'package:cliente/presentation/bloc/vehicle_location/vehicle_location_bloc.dart';
import 'package:cliente/presentation/bloc/websocket/websocket_bloc.dart';
import 'package:cliente/presentation/pages/home_page.dart';

void main() {
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rutas App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => getIt<RouteSelectionBloc>()),
          BlocProvider(create: (context) => getIt<UserLocationBloc>()),
          BlocProvider(create: (context) => getIt<VehicleLocationBloc>()),
          BlocProvider(create: (context) => getIt<WebSocketBloc>()),
        ],
        child: const HomePage(),
      ),
    );
  }
}
