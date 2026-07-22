import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  // Local IP (same Wi-Fi as dev machine)
  static const String _localUrl = 'http://192.168.1.7:5159';

  // Production API (Azure App Service). Used for release/TestFlight builds and
  // as the fallback whenever the local dev server is unreachable.
  static const String _productionUrl =
      'https://ideawellness-api-fmeadkcma3agbghc.centralus-01.azurewebsites.net';

  static String? _resolvedUrl;

  /// Returns the resolved base URL.
  /// Falls back to the production API if [resolveBaseUrl] hasn't run yet.
  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (kIsWeb) return 'https://localhost:7057';
    return _resolvedUrl ?? _productionUrl;
  }

  /// Call once in main() before runApp.
  /// On Android/iOS debug builds: tries the local IP first (2 s timeout),
  /// falls back to the production API if unreachable. Release builds always
  /// use the production API.
  static Future<void> resolveBaseUrl() async {
    if (_configuredBaseUrl.isNotEmpty) return;

    // Release builds (TestFlight / App Store) always use the production API.
    if (kReleaseMode) {
      _resolvedUrl = _productionUrl;
      debugPrint('[ApiConfig] Release build — using production: $_productionUrl');
      return;
    }

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
      _resolvedUrl = _productionUrl;
      debugPrint('[ApiConfig] Local unreachable — using production: $_productionUrl');
    }
  }
}
