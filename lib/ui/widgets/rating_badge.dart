import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// "★ 9.2" — used on posters, list tiles and the details screen.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, this.background});

  final double rating;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Rated ${rating.toStringAsFixed(1)} out of 10',
      excludeSemantics: true,
      child: Container(
        padding: background == null ? null : const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: background == null
            ? null
            : BoxDecoration(color: background, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
            const SizedBox(width: 2),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
