import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/show.dart';
import '../screens/show_details_screen.dart';
import 'rating_badge.dart';
import 'show_poster.dart';

/// A row with poster, title, years, genres and rating.
/// Used for search results and the watchlist.
class ShowListTile extends StatelessWidget {
  const ShowListTile({super.key, required this.show, this.trailing});

  final Show show;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    const secondary = TextStyle(fontSize: 13, color: AppColors.textSecondary);

    return InkWell(
      onTap: () => ShowDetailsScreen.open(context, show),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            ShowPoster(url: show.imageMedium, width: 64, height: 90, borderRadius: 10),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    show.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(show.yearRange, style: secondary),
                  Text(show.genresText, style: secondary, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (show.rating != null) ...[
                    const SizedBox(height: 4),
                    RatingBadge(rating: show.rating!),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
