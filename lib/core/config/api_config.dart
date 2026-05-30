import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'https://transpleural-madeleine-lodgeable.ngrok-free.dev',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'https://localhost:7057';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://transpleural-madeleine-lodgeable.ngrok-free.dev';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'https://transpleural-madeleine-lodgeable.ngrok-free.dev';
    } else {
      return 'https://localhost:7057';
    }
  }
}
