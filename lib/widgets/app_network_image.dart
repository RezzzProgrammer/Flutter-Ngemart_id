import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Cached network image that decodes at a bounded size to keep memory low.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.memCacheWidth = 420,
    this.fit = BoxFit.contain,
  });

  final String url;
  final int memCacheWidth;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _ImageFallback();

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      memCacheWidth: memCacheWidth,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, __) => const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (_, __, ___) => const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.primaryInk,
        size: 32,
      ),
    );
  }
}
