import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebSocketService {
  static final String wsUrl = dotenv.env['ws'] ?? '';
  late WebSocketChannel channel;

  void connect({
    required Function(String message) onMessage,
    required Function(bool connected) onStatus,
  }) {
    try {
      channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      onStatus(true);

      channel.stream.listen(
        (message) => onMessage(message),
        onError: (error) {
          print('WebSocket error: $error');
          onStatus(false);
        },
        onDone: () {
          print('WebSocket closed');
          onStatus(false);
        },
      );
    } catch (e) {
      print('WebSocket connection failed: $e');
      onStatus(false);
    }
  }

  void disconnect() {
    channel.sink.close();
  }
}