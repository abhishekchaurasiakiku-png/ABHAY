import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/api_constants.dart';

/// WebSocket manager for live location streaming during active SOS.
/// Features auto-reconnect with exponential backoff.
class WebSocketClient {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  bool _isConnected = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _heartbeatInterval = Duration(seconds: 15);

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  /// Stream of incoming messages from the server.
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  /// Stream of connection state changes.
  Stream<bool> get connectionState => _connectionController.stream;

  bool get isConnected => _isConnected;

  /// Connect to the live tracking WebSocket for an active SOS incident.
  Future<void> connect({
    required String incidentId,
    required String authToken,
  }) async {
    _shouldReconnect = true;
    _reconnectAttempts = 0;

    final uri = Uri.parse(
      '${ApiConstants.wsLiveTracking}?incidentId=$incidentId&token=$authToken',
    );

    await _establishConnection(uri);
  }

  Future<void> _establishConnection(Uri uri) async {
    try {
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;

      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionController.add(true);

      _startHeartbeat();

      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data as String) as Map<String, dynamic>;
            _messageController.add(message);
          } catch (e) {
            print('[WS] Failed to parse message: $e');
          }
        },
        onError: (error) {
          print('[WS] Error: $error');
          _handleDisconnection(uri);
        },
        onDone: () {
          print('[WS] Connection closed');
          _handleDisconnection(uri);
        },
      );
    } catch (e) {
      print('[WS] Connection failed: $e');
      _handleDisconnection(uri);
    }
  }

  /// Send live location update to the server.
  void sendLocation({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
  }) {
    if (!_isConnected || _channel == null) return;

    final message = jsonEncode({
      'type': 'location_update',
      'data': {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'speed': speed,
        'timestamp': DateTime.now().toIso8601String(),
      },
    });

    _channel!.sink.add(message);
  }

  /// Send a generic message to the server.
  void send(Map<String, dynamic> data) {
    if (!_isConnected || _channel == null) return;
    _channel!.sink.add(jsonEncode(data));
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_isConnected) {
        send({'type': 'heartbeat', 'timestamp': DateTime.now().toIso8601String()});
      }
    });
  }

  void _handleDisconnection(Uri uri) {
    _isConnected = false;
    _connectionController.add(false);
    _heartbeatTimer?.cancel();

    if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      final delay = Duration(
        seconds: (1 << _reconnectAttempts).clamp(1, 30), // Exponential backoff, max 30s
      );
      _reconnectAttempts++;
      print('[WS] Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)');

      _reconnectTimer = Timer(delay, () => _establishConnection(uri));
    }
  }

  /// Gracefully disconnect from the WebSocket.
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
    _isConnected = false;
    _connectionController.add(false);
  }

  /// Clean up resources.
  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
}
