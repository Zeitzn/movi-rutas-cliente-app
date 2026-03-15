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
      _stompClient = StompClient(
        config: StompConfig(
          url: WebSocketConstants.websocketUrl,
          onConnect: (StompFrame frame) {
            _isConnected = true;
            print('STOMP Subscriber Connected');
            _subscribeToTopic();
          },
          onDisconnect: (StompFrame frame) {
            _isConnected = false;
            print('STOMP Subscriber Disconnected');
          },
          onWebSocketError: (error) {
            print('STOMP WebSocket Error: $error');
          },
          onStompError: (StompFrame frame) {
            print('STOMP Protocol Error: ${frame.headers}');
          },
          reconnectDelay: WebSocketConstants.reconnectDelay,
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

    _unsubscribeCallback = _stompClient!.subscribe(
      destination: WebSocketConstants.websocketTopic,
      callback: (StompFrame frame) {
        _handleMessage(frame.body);
      },
    );

    print('Subscribed to ${WebSocketConstants.websocketTopic}');
  }

  void _handleMessage(String? body) {
    if (body == null || body.isEmpty) return;

    try {
      final Map<String, dynamic> message = jsonDecode(body);
      print('Received: $message');

      for (final listener in _listeners) {
        listener(message);
      }
    } catch (e) {
      print('Error parsing message: $e');
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
    _listeners.clear();
  }
}
