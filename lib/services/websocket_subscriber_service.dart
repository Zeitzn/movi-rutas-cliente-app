import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_handler.dart';

typedef MessageCallback = void Function(WebSocketMessage message);

class WebSocketMessage {
  final Map<String, dynamic> data;
  final String routeId;

  WebSocketMessage({required this.data, required this.routeId});
}

class WebSocketSubscriberService {
  StompClient? _stompClient;
  bool _isConnected = false;
  final List<MessageCallback> _listeners = [];
  final Map<String, StompUnsubscribe> _subscriptions = {};
  String _baseUrl = 'ws://mr-ws.todoprogramacionapi.xyz/channels';

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      print('STOMP: Connecting to $_baseUrl...');

      _stompClient = StompClient(
        config: StompConfig(
          url: _baseUrl,
          onConnect: (StompFrame frame) {
            _isConnected = true;
            print('STOMP: Connected successfully');
          },
          onDisconnect: (StompFrame frame) {
            _isConnected = false;
            print('STOMP: Disconnected');
          },
          onWebSocketError: (error) {
            print('STOMP WS Error: $error');
            print('STOMP Error type: ${error.runtimeType}');
          },
          onStompError: (StompFrame frame) {
            print('STOMP Protocol Error: ${frame.headers}');
            print('STOMP Error body: ${frame.body}');
          },
          reconnectDelay: const Duration(seconds: 5),
          heartbeatOutgoing: const Duration(seconds: 10),
          heartbeatIncoming: const Duration(seconds: 10),
        ),
      );

      _stompClient!.activate();

      int attempts = 0;
      while (!_isConnected && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
        print('STOMP: Waiting for connection... ($attempts)');
      }

      if (!_isConnected) {
        print('STOMP: Connection timeout after ${attempts * 500}ms');
      }
    } catch (e) {
      print('STOMP Connection exception: $e');
      _isConnected = false;
      rethrow;
    }
  }

  void subscribeToRoute(String routeCode) {
    if (_stompClient == null || !_isConnected) {
      print('STOMP: Cannot subscribe, not connected');
      return;
    }

    if (_subscriptions.containsKey(routeCode)) {
      print('STOMP: Already subscribed to route $routeCode');
      return;
    }

    final topic = '/topic/channel/PE/AYAC/$routeCode';
    final unsubscribe = _stompClient!.subscribe(
      destination: topic,
      callback: (StompFrame frame) {
        print('📩 Received on $topic: ${frame.body}');
        _handleMessage(frame.body, routeCode);
      },
    );

    _subscriptions[routeCode] = unsubscribe;
    print('Subscribed to $topic');
  }

  void unsubscribeFromRoute(String routeCode) {
    final unsubscribe = _subscriptions.remove(routeCode);
    if (unsubscribe != null) {
      unsubscribe();
      print('Unsubscribed from /topic/channel/PE/AYAC/$routeCode');
    }
  }

  Set<String> get subscribedRoutes => _subscriptions.keys.toSet();

  void _handleMessage(String? body, String routeCode) {
    if (body == null || body.isEmpty) return;

    try {
      final Map<String, dynamic> message = jsonDecode(body);

      final remitente = message['remitente'] ?? 'unknown';
      final latitud = message['latitud'];
      final longitud = message['longitud'];
      final contenido = message['contenido'] ?? '';
      final timestamp = message['timestamp'] ?? '';
      final velocidad = message['velocidad'];
      final precision = message['precision'];

      print('========== WS MESSAGE RECEIVED ==========');
      print('Remitente: $remitente');
      print('Latitud: $latitud');
      print('Longitud: $longitud');
      print('Contenido: $contenido');
      print('Timestamp: $timestamp');
      print('Velocidad: $velocidad');
      print('Precision: $precision');
      print('==========================================');

      final wsMessage = WebSocketMessage(data: message, routeId: routeCode);
      for (final listener in _listeners) {
        listener(wsMessage);
      }
    } catch (e) {
      print('WS Error parsing message: $e');
      print('WS Raw body: $body');
    }
  }

  void addListener(MessageCallback callback) {
    _listeners.add(callback);
  }

  void removeListener(MessageCallback callback) {
    _listeners.remove(callback);
  }

  void unsubscribeAll() {
    for (final unsubscribe in _subscriptions.values) {
      unsubscribe();
    }
    _subscriptions.clear();
    print('Unsubscribed from all routes');
  }

  Future<void> disconnect() async {
    unsubscribeAll();
    if (_stompClient == null) return;
    _stompClient!.deactivate();
    _stompClient = null;
    _isConnected = false;
  }
}
