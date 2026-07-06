import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Resolve backend URL: tries local IP first, falls back to ngrok
  await ApiConfig.resolveBaseUrl();

  runApp(const ProviderScope(child: IdeaWellnessApp()));
}
