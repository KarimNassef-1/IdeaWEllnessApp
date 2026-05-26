import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io'; // 🟢 Make sure you import this!

import 'app.dart';

// 🟢 Add this class **above** main()
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 🟢 Add this next line before runApp()
  HttpOverrides.global = MyHttpOverrides();

  runApp(const ProviderScope(child: IdeaWellnessApp()));
}
