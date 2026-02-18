import 'package:equatable/equatable.dart';

abstract class WebSocketState extends Equatable {
  const WebSocketState();

  @override
  List<Object?> get props => [];
}

class WebSocketInitial extends WebSocketState {
  const WebSocketInitial();
}

class WebSocketConnecting extends WebSocketState {
  const WebSocketConnecting();
}

class WebSocketConnected extends WebSocketState {
  final String routeId;

  const WebSocketConnected({required this.routeId});

  @override
  List<Object?> get props => [routeId];
}

class WebSocketDisconnected extends WebSocketState {
  const WebSocketDisconnected();
}

class WebSocketError extends WebSocketState {
  final String message;

  const WebSocketError({required this.message});

  @override
  List<Object?> get props => [message];
}
