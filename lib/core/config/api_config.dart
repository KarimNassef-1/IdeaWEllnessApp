import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'https://localhost:7057';
    } else if (Platform.isAndroid || Platform.isIOS) {
      return 'http://192.168.1.7:5159';
    } else {
      return 'https://localhost:7057';
    }
  }
}
