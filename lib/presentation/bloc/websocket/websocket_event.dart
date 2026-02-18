import 'package:equatable/equatable.dart';

abstract class WebSocketEvent extends Equatable {
  const WebSocketEvent();

  @override
  List<Object?> get props => [];
}

class ConnectWebSocketEvent extends WebSocketEvent {
  final String routeId;
  final String websocketUrl;

  const ConnectWebSocketEvent({
    required this.routeId,
    required this.websocketUrl,
  });

  @override
  List<Object?> get props => [routeId, websocketUrl];
}

class DisconnectWebSocketEvent extends WebSocketEvent {
  const DisconnectWebSocketEvent();
}

class WebSocketMessageReceivedEvent extends WebSocketEvent {
  final dynamic data;

  const WebSocketMessageReceivedEvent({required this.data});

  @override
  List<Object?> get props => [data];
}
