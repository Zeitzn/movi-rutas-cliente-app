class WebSocketConstants {
  static const Duration reconnectDelay = Duration(seconds: 5);
  static const Duration maxReconnectDelay = Duration(seconds: 30);
  static const Duration messageTimeout = Duration(seconds: 10);

  static const String websocketUrl = 'ws://mr-ws.todoprogramacionapi.xyz/channels';
  static const String websocketTopic = '/topic/channel/PE/AYAC/001';
  static const String websocketDestination = '/app/channel/PE/AYAC/001';
  static const String websocketRemitente = 'cliente_app';
}
