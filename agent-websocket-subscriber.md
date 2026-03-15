# Agente: WebSocket Subscriber para Flutter

## Objetivo
Configurar una aplicación móvil Flutter para recibir eventos en tiempo real a través de un WebSocket con protocolo STOMP.

## Dependencias requeridas

Agregar al `pubspec.yaml`:

```yaml
dependencies:
  stomp_dart_client: ^0.4.4
```

## Pasos de configuración

### 1. Definir constantes de WebSocket

Crear un archivo de constantes (ej: `lib/core/constants/app_constants.dart`) con:

```dart
class AppConstants {
  // URL del servidor WebSocket STOMP
  static const String websocketUrl = 'ws://TU_SERVIDOR/channels';
  
  // Topic al que se suscribe para recibir mensajes
  static const String websocketTopic = '/topic/channel/PE/AYAC/001';
  
  // Destination para enviar mensajes (opcional para subscriber)
  static const String websocketDestination = '/app/channel/PE/AYAC/001';
  
  // Identificador del remitente
  static const String websocketRemitente = 'mi_app';
}
```

### 2. Crear el servicio WebSocket Subscriber

Crear `lib/services/websocket_subscriber_service.dart`:

```dart
import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../core/constants/app_constants.dart';

typedef MessageCallback = void Function(Map<String, dynamic> message);

class WebSocketSubscriberService {
  StompClient? _stompClient;
  bool _isConnected = false;
  final List<MessageCallback> _listeners = [];
  String? _currentSubscriptionId;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      _stompClient = StompClient(
        config: StompConfig(
          url: AppConstants.websocketUrl,
          onConnect: (StompFrame frame) {
            _isConnected = true;
            print('✅ STOMP Subscriber Connected');
            _subscribeToTopic();
          },
          onDisconnect: (StompFrame frame) {
            _isConnected = false;
            print('❌ STOMP Subscriber Disconnected');
          },
          onWebSocketError: (error) {
            print('❌ STOMP WebSocket Error: $error');
          },
          onStompError: (StompFrame frame) {
            print('❌ STOMP Protocol Error: ${frame.headers}');
          },
          reconnectDelay: const Duration(seconds: 5),
          heartbeatOutgoing: const Duration(seconds: 10),
          heartbeatIncoming: const Duration(seconds: 10),
        ),
      );

      _stompClient!.activate();
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      print('WebSocket STOMP connection error: $e');
      _isConnected = false;
      rethrow;
    }
  }

  void _subscribeToTopic() {
    if (_stompClient == null || !_isConnected) return;

    _currentSubscriptionId = _stompClient!.subscribe(
      destination: AppConstants.websocketTopic,
      callback: (StompFrame frame) {
        _handleMessage(frame.body);
      },
    ).id;

    print('👂 Subscribed to ${AppConstants.websocketTopic}');
  }

  void _handleMessage(String? body) {
    if (body == null || body.isEmpty) return;

    try {
      final Map<String, dynamic> message = jsonDecode(body);
      print('📩 Received: $message');
      
      for (final listener in _listeners) {
        listener(message);
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  // Agregar listener para recibir mensajes
  void addListener(MessageCallback callback) {
    _listeners.add(callback);
  }

  // Remover listener
  void removeListener(MessageCallback callback) {
    _listeners.remove(callback);
  }

  // Desuscribirse del topic
  void unsubscribe() {
    if (_currentSubscriptionId != null && _stompClient != null) {
      _stompClient!.unsubscribe(
        id: _currentSubscriptionId!,
        destination: AppConstants.websocketTopic,
      );
      _currentSubscriptionId = null;
      print('👋 Unsubscribed from ${AppConstants.websocketTopic}');
    }
  }

  Future<void> disconnect() async {
    unsubscribe();
    if (_stompClient == null) return;
    _stompClient!.deactivate();
    _stompClient = null;
    _isConnected = false;
    _listeners.clear();
  }
}
```

### 3. Integrar en la aplicación

#### Opción A: Uso directo en widget

```dart
final subscriberService = WebSocketSubscriberService();

// Conectar al iniciar
await subscriberService.connect();

// Agregar listener
subscriberService.addListener((message) {
  // Procesar mensaje recibido
  final remitente = message['remitente'];
  final latitud = message['latitud'];
  final longitud = message['longitud'];
  
  print('Mensaje de $remitente: ($latitud, $longitud)');
});

// En dispose
@override
void dispose() {
  subscriberService.disconnect();
  super.dispose();
}
```

#### Opción B: Con BLoC (recomendado)

Crear `lib/bloc/websocket_event_bloc.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/websocket_subscriber_service.dart';

// Events
abstract class WebSocketEvent {}
class WebSocketConnected extends WebSocketEvent {}
class WebSocketDisconnected extends WebSocketEvent {}
class WebSocketMessageReceived extends WebSocketEvent {
  final Map<String, dynamic> message;
  WebSocketMessageReceived(this.message);
}

// State
class WebSocketState {
  final bool isConnected;
  final List<Map<String, dynamic>> messages;
  
  WebSocketState({
    this.isConnected = false,
    this.messages = const [],
  });
  
  WebSocketState copyWith({
    bool? isConnected,
    List<Map<String, dynamic>>? messages,
  }) {
    return WebSocketState(
      isConnected: isConnected ?? this.isConnected,
      messages: messages ?? this.messages,
    );
  }
}

// BLoC
class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
  final WebSocketSubscriberService _service;

  WebSocketBloc(this._service) : super(WebSocketState()) {
    on<WebSocketConnected>(_onConnected);
    on<WebSocketDisconnected>(_onDisconnected);
    on<WebSocketMessageReceived>(_onMessageReceived);
    
    _service.addListener((message) {
      add(WebSocketMessageReceived(message));
    });
  }

  void _onConnected(WebSocketConnected event, Emitter<WebSocketState> emit) {
    emit(state.copyWith(isConnected: true));
  }

  void _onDisconnected(WebSocketDisconnected event, Emitter<WebSocketState> emit) {
    emit(state.copyWith(isConnected: false));
  }

  void _onMessageReceived(WebSocketMessageReceived event, Emitter<WebSocketState> emit) {
    final newMessages = [...state.messages, event.message];
    emit(state.copyWith(messages: newMessages));
  }
}
```

## Estructura del mensaje esperado

```json
{
  "remitente": "conductor_app",
  "contenido": "Coordenadas GPS: -12.0464, -77.0428",
  "latitud": -12.0464,
  "longitud": -77.0428,
  "timestamp": "2024-01-15T10:30:00.000Z",
  "velocidad": 30.5,
  "precision": 5.0
}
```

## Configuración por entorno

| Entorno | URL WebSocket | Topic |
|---------|---------------|-------|
| Desarrollo | `ws://192.168.x.x:8080/channels` | `/topic/channel/PE/AYAC/001` |
| Producción | `ws://mr-ws.todoprogramacionapi.xyz/channels` | `/topic/channel/PE/AYAC/001` |

## Notas

- El servicio implementa **reconexión automática** cada 5 segundos
- Soporta **múltiples listeners** para diferentes partes de la UI
- Se puede **desuscribir** sin desconectar completamente
- El protocolo es **STOMP** sobre WebSocket
- Los mensajes se reciben en formato JSON
