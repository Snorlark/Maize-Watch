import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/environment.dart';
import '../storage/secure_storage.dart';

class SocketService {
  static SocketService? _instance;
  IO.Socket? _socket;

  static SocketService get instance {
    _instance ??= SocketService._internal();
    return _instance!;
  }

  SocketService._internal();

  Future<void> connect() async {
    if (_socket?.connected == true) return;

    try {
      final token = await SecureStorage.getToken();
      if (token == null) return;

      _socket = IO.io(AppConfig.baseUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {'token': token},
      });

      _socket!.connect();

      _socket!.onConnect((_) {
        print('🔌 Socket.IO connected');
      });

      _socket!.onDisconnect((_) {
        print('🔌 Socket.IO disconnected');
      });

      _socket!.onError((error) {
        print('🔌 Socket.IO error: $error');
      });
    } catch (e) {
      print('🔌 Socket.IO connection failed: $e');
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void onAnalyticsUpdated(Function(Map<String, dynamic>) callback) {
    _socket?.on('analytics:updated', (data) {
      print('🔌 Received analytics update: $data');
      callback(data);
    });
  }

  void offAnalyticsUpdated() {
    _socket?.off('analytics:updated');
  }

  bool get isConnected => _socket?.connected == true;
}
