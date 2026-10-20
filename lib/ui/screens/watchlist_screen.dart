import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/watchlist/watchlist_bloc.dart';
import '../widgets/message_view.dart';
import '../widgets/show_list_tile.dart';
import '../widgets/watchlist_icon_button.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key, required this.onExplore});

  /// Called by "Explore Shows" to jump back to the Home tab.
  final VoidCallback onExplore;

  Future<void> _confirmClear(BuildContext context) async {
    final bloc = context.read<WatchlistBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear watchlist?'),
        content: const Text('All saved shows will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
        ],
      ),
    );
    if (confirmed == true) bloc.add(const WatchlistCleared());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Watchlist'),
            actions: [
              if (!state.isEmpty)
                IconButton(
                  tooltip: 'Clear watchlist',
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => _confirmClear(context),
                ),
            ],
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.isEmpty
                  ? MessageView(
                      icon: Icons.favorite_border_rounded,
                      title: 'Your watchlist is empty',
                      message: 'Discover amazing shows and save them here to watch later.',
                      actionLabel: 'Explore Shows',
                      onAction: onExplore,
                    )
                  : ListView.separated(
                      itemCount: state.shows.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, indent: 94),
                      itemBuilder: (context, index) {
                        final show = state.shows[index];
                        return ShowListTile(show: show, trailing: WatchlistIconButton(show: show));
                      },
                    ),
        );
      },
    );
  }
}
