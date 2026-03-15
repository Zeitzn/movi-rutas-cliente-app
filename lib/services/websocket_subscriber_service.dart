import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_handler.dart';
import 'package:cliente/core/constants/websocket_constants.dart';

typedef MessageCallback = void Function(Map<String, dynamic> message);

class WebSocketSubscriberService {
  StompClient? _stompClient;
  bool _isConnected = false;
  final List<MessageCallback> _listeners = [];
  StompUnsubscribe? _unsubscribeCallback;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      print('STOMP: Connecting to ${WebSocketConstants.websocketUrl}...');

      _stompClient = StompClient(
        config: StompConfig(
          url: WebSocketConstants.websocketUrl,
          onConnect: (StompFrame frame) {
            _isConnected = true;
            print('STOMP: Connected successfully');
            _subscribeToTopic();
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
          reconnectDelay: WebSocketConstants.reconnectDelay,
          heartbeatOutgoing: const Duration(seconds: 10),
          heartbeatIncoming: const Duration(seconds: 10),
        ),
      );

      _stompClient!.activate();

      // Wait for connection
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

  void _subscribeToTopic() {
    if (_stompClient == null || !_isConnected) return;

    _unsubscribeCallback = _stompClient!.subscribe(
      destination: WebSocketConstants.websocketTopic,
      callback: (StompFrame frame) {
        print('📩 Received on client: ${frame.body}');
        _handleMessage(frame.body);
      },
    );

    print('Subscribed to ${WebSocketConstants.websocketTopic}');
  }

  void _handleMessage(String? body) {
    if (body == null || body.isEmpty) return;

    try {
      final Map<String, dynamic> message = jsonDecode(body);

      // Extraer datos del mensaje
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

      for (final listener in _listeners) {
        listener(message);
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

  void unsubscribe() {
    if (_unsubscribeCallback != null) {
      _unsubscribeCallback!();
      _unsubscribeCallback = null;
      print('Unsubscribed from ${WebSocketConstants.websocketTopic}');
    }
  }

  Future<void> disconnect() async {
    unsubscribe();
    if (_stompClient == null) return;
    _stompClient!.deactivate();
    _stompClient = null;
    _isConnected = false;
  }
}
