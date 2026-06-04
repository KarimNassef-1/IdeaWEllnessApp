import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  // Local IP (same Wi-Fi as dev machine)
  static const String _localUrl = 'http://192.168.1.7:5159';

  // ngrok tunnel (works from anywhere)
  static const String _ngrokUrl =
      'https://transpleural-madeleine-lodgeable.ngrok-free.dev';

  static String? _resolvedUrl;

  /// Returns the resolved base URL.
  /// Falls back to ngrok if [resolveBaseUrl] hasn't run yet.
  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (kIsWeb) return 'https://localhost:7057';
    return _resolvedUrl ?? _ngrokUrl;
  }

  /// Call once in main() before runApp.
  /// On Android/iOS: tries the local IP first (2 s timeout),
  /// falls back to ngrok if unreachable.
  static Future<void> resolveBaseUrl() async {
    if (_configuredBaseUrl.isNotEmpty) return;

    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      _resolvedUrl = 'https://localhost:7057';
      return;
    }

    // Mobile: probe local server with a raw TCP socket (no HTTP overhead,
    // no specific endpoint needed — just checks if the port is open).
    try {
      final socket = await Socket.connect(
        '192.168.1.7',
        5159,
        timeout: const Duration(seconds: 2),
      );
      socket.destroy();
      _resolvedUrl = _localUrl;
      debugPrint('[ApiConfig] Using local URL: $_localUrl');
    } catch (_) {
      _resolvedUrl = _ngrokUrl;
      debugPrint('[ApiConfig] Local unreachable — using ngrok: $_ngrokUrl');
    }
  }
}
