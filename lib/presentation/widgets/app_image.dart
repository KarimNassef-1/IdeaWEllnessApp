import 'package:flutter/material.dart';

import '../../core/config/api_config.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackAsset = 'img/idea-profile.png',
  });

  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String fallbackAsset;

  String get _resolvedSource {
    if (source.startsWith('/')) return '${ApiConfig.baseUrl}$source';
    return source;
  }

  bool get _isNetwork =>
      _resolvedSource.startsWith('http://') ||
      _resolvedSource.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (_isNetwork) {
      return Image.network(
        _resolvedSource,
        width: width,
        height: height,
        fit: fit,
        headers: const {'ngrok-skip-browser-warning': 'true'},
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            fallbackAsset,
            width: width,
            height: height,
            fit: fit,
          );
        },
      );
    }

    return Image.asset(
      source.isEmpty ? fallbackAsset : source,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          fallbackAsset,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }
}
