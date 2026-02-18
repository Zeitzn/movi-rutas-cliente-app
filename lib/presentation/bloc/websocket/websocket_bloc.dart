import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cliente/core/network/websocket_service.dart';
import 'package:cliente/presentation/bloc/websocket/websocket_event.dart';
import 'package:cliente/presentation/bloc/websocket/websocket_state.dart';

class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
  final WebSocketService webSocketService;

  WebSocketBloc({required this.webSocketService})
    : super(const WebSocketInitial()) {
    on<ConnectWebSocketEvent>(_onConnectWebSocket);
    on<DisconnectWebSocketEvent>(_onDisconnectWebSocket);
  }

  Future<void> _onConnectWebSocket(
    ConnectWebSocketEvent event,
    Emitter<WebSocketState> emit,
  ) async {
    try {
      emit(const WebSocketConnecting());
      await webSocketService.connect(event.websocketUrl);
      emit(WebSocketConnected(routeId: event.routeId));
    } catch (e) {
      emit(WebSocketError(message: e.toString()));
    }
  }

  Future<void> _onDisconnectWebSocket(
    DisconnectWebSocketEvent event,
    Emitter<WebSocketState> emit,
  ) async {
    webSocketService.disconnect();
    emit(const WebSocketDisconnected());
  }
}
