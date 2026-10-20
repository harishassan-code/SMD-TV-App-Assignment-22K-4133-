import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/shows/shows_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/message_view.dart';
import '../widgets/show_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Asks for the next page when the user gets close to the bottom.
  /// Not after a failure, so we don't retry on every scroll: the user taps "Retry".
  void _onScroll() {
    final position = _scrollController.position;
    final bloc = context.read<ShowsBloc>();
    if (position.pixels >= position.maxScrollExtent - 600 &&
        bloc.state.status == ShowsStatus.success) {
      bloc.add(const ShowsFetched());
    }
  }

  void _retry() => context.read<ShowsBloc>().add(const ShowsFetched());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<ShowsBloc, ShowsState>(
        builder: (context, state) {
          if (state.shows.isEmpty) {
            return switch (state.status) {
              ShowsStatus.failure => MessageView(
                  icon: Icons.wifi_off_rounded,
                  title: 'Could not load shows',
                  message: state.errorMessage,
                  actionLabel: 'Retry',
                  onAction: _retry,
                ),
              ShowsStatus.success => const MessageView(
                  icon: Icons.tv_off_rounded,
                  title: 'No shows available',
                ),
              _ => const Center(child: CircularProgressIndicator()),
            };
          }

          final topRated = state.topRated;
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _Header(onSearchTap: widget.onSearchTap)),
              if (topRated.isNotEmpty) ...[
                const SliverToBoxAdapter(child: _SectionTitle('Top Rated')),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 250,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: topRated.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => SizedBox(
                        width: 140,
                        child: ShowCard(show: topRated[index]),
                      ),
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: _SectionTitle('All Shows')),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 140, // 3 columns on phones
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: state.shows.length,
                  itemBuilder: (context, index) => ShowCard(show: state.shows[index]),
                ),
              ),
              SliverToBoxAdapter(child: _ListFooter(state: state, onRetry: _retry)),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hello,', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          const Text(
            'TV Explorer! 👋',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Looks like a search field; tapping it opens the Search tab.
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onSearchTap,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    SizedBox(width: 12),
                    Text('Search shows...', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }
}

/// Bottom of the grid: a spinner while the next page loads,
/// an inline error with "Retry", or an end-of-list note.
class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state, required this.onRetry});

  final ShowsState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (state.status == ShowsStatus.failure) {
      child = Column(
        children: [
          Text(
            state.errorMessage ?? 'Could not load more shows.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      );
    } else if (state.hasReachedMax) {
      child = const Text("You've seen all the shows!", style: TextStyle(color: AppColors.textSecondary));
    } else {
      child = const CircularProgressIndicator();
    }
    return Padding(padding: const EdgeInsets.all(24), child: Center(child: child));
  }
}
