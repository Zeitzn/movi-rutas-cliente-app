class WebSocketConstants {
  static const Duration reconnectDelay = Duration(seconds: 5);
  static const Duration maxReconnectDelay = Duration(seconds: 30);
  static const Duration messageTimeout = Duration(seconds: 10);
}
