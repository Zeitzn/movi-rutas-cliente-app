import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:cliente/core/errors/exceptions.dart';

abstract class WebSocketService {
  Future<void> connect(String url);
  void disconnect();
  void send(String message);
  Stream<dynamic> get stream;
  bool get isConnected;
}

class WebSocketServiceImpl implements WebSocketService {
  late WebSocketChannel _channel;
  bool _isConnected = false;

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<dynamic> get stream {
    if (!_isConnected) {
      throw WebSocketException(message: 'WebSocket is not connected');
    }
    return _channel.stream;
  }

  @override
  Future<void> connect(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      await _channel.ready;
      _isConnected = true;
    } catch (e) {
      _isConnected = false;
      throw WebSocketException(
        message: 'Failed to connect to WebSocket: ${e.toString()}',
      );
    }
  }

  @override
  void disconnect() {
    if (_isConnected) {
      _channel.sink.close();
      _isConnected = false;
    }
  }

  @override
  void send(String message) {
    if (!_isConnected) {
      throw WebSocketException(message: 'WebSocket is not connected');
    }
    _channel.sink.add(message);
  }
}
