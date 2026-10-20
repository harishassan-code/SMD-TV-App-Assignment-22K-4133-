import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/watchlist/watchlist_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/show.dart';

/// Heart button that adds/removes [show] from the watchlist.
/// BlocSelector rebuilds it only when this show's saved state changes.
class WatchlistIconButton extends StatelessWidget {
  const WatchlistIconButton({super.key, required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WatchlistBloc, WatchlistState, bool>(
      selector: (state) => state.contains(show.id),
      builder: (context, isSaved) => IconButton(
        tooltip: isSaved ? 'Remove from watchlist' : 'Add to watchlist',
        icon: Icon(
          isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isSaved ? AppColors.heart : null,
        ),
        onPressed: () => context.read<WatchlistBloc>().add(WatchlistShowToggled(show)),
      ),
    );
  }
}
