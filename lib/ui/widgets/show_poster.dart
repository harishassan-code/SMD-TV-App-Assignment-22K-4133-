import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A network image with rounded corners.
/// Shows a placeholder icon while loading, when [url] is null,
/// or when the image fails to load.
class ShowPoster extends StatelessWidget {
  const ShowPoster({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.placeholderIcon = Icons.tv_rounded,
  });

  final String? url;
  final double? width;
  final double? height;
  final double borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: AppColors.surfaceLight,
      child: Center(child: Icon(placeholderIcon, color: AppColors.textSecondary)),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: url == null
            ? placeholder
            : Image.network(
                url!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : placeholder,
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }
}
