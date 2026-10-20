import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/show.dart';
import '../screens/show_details_screen.dart';
import 'rating_badge.dart';
import 'show_poster.dart';

/// Poster + title + genres, used in the home grid and the "Top Rated" row.
/// The poster fills whatever height the parent gives it.
class ShowCard extends StatelessWidget {
  const ShowCard({super.key, required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => ShowDetailsScreen.open(context, show),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ShowPoster(url: show.imageMedium),
                if (show.rating != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: RatingBadge(rating: show.rating!, background: Colors.black54),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            show.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            show.genresText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
