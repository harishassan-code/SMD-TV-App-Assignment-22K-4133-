import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/show_details/show_details_bloc.dart';
import '../../bloc/watchlist/watchlist_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/cast_member.dart';
import '../../data/models/episode.dart';
import '../../data/models/show.dart';
import '../../data/repositories/show_repository.dart';
import '../widgets/message_view.dart';
import '../widgets/rating_badge.dart';
import '../widgets/show_poster.dart';
import '../widgets/watchlist_icon_button.dart';

/// Poster, info and three tabs (Overview, Episodes, Cast) for one show.
///
/// It opens with the [show] we already have from the list, so the header
/// appears instantly, while [ShowDetailsBloc] loads the full details,
/// cast and episodes.
class ShowDetailsScreen extends StatefulWidget {
  const ShowDetailsScreen({super.key, required this.show});

  final Show show;

  /// Opens the screen with its own [ShowDetailsBloc].
  static Future<void> open(BuildContext context, Show show) {
    final repository = context.read<ShowRepository>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ShowDetailsBloc(repository)..add(ShowDetailsRequested(show.id)),
          child: ShowDetailsScreen(show: show),
        ),
      ),
    );
  }

  @override
  State<ShowDetailsScreen> createState() => _ShowDetailsScreenState();
}

class _ShowDetailsScreenState extends State<ShowDetailsScreen> with SingleTickerProviderStateMixin {
  // The selected tab and season are plain UI state, so they live here, not in a BLoC.
  late final TabController _tabController = TabController(length: 3, vsync: this)
    ..addListener(() => setState(() {}));
  int? _selectedSeason;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _retry() => context.read<ShowDetailsBloc>().add(ShowDetailsRequested(widget.show.id));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ShowDetailsBloc, ShowDetailsState>(
        builder: (context, state) {
          final show = state is ShowDetailsLoaded ? state.show : widget.show;
          final seasonCount = state is ShowDetailsLoaded ? state.seasons.length : null;

          return CustomScrollView(
            slivers: [
              _DetailsAppBar(show: show),
              SliverToBoxAdapter(child: _ShowInfo(show: show, seasonCount: seasonCount)),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    dividerColor: AppColors.surfaceLight,
                    tabs: const [Tab(text: 'Overview'), Tab(text: 'Episodes'), Tab(text: 'Cast')],
                  ),
                ),
              ),
              ..._tabContent(state, show),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _tabContent(ShowDetailsState state, Show show) {
    // Overview only needs the show, which we always have.
    if (_tabController.index == 0) return [SliverToBoxAdapter(child: _OverviewTab(show: show))];

    return switch (state) {
      ShowDetailsLoading() => const [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ShowDetailsFailure(:final message) => [
          SliverToBoxAdapter(
            child: MessageView(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load details',
              message: message,
              actionLabel: 'Retry',
              onAction: _retry,
            ),
          ),
        ],
      ShowDetailsLoaded(:final seasons, :final cast) =>
        _tabController.index == 1 ? _episodeSlivers(seasons) : _castSlivers(cast),
    };
  }

  List<Widget> _episodeSlivers(Map<int, List<Episode>> seasons) {
    if (seasons.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: MessageView(icon: Icons.movie_outlined, title: 'No episodes available'),
        ),
      ];
    }

    final season = seasons.containsKey(_selectedSeason) ? _selectedSeason! : seasons.keys.first;
    final episodes = seasons[season]!;

    return [
      SliverToBoxAdapter(
        child: SizedBox(
          height: 64,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            children: [
              for (final number in seasons.keys)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('Season $number'),
                    selected: number == season,
                    onSelected: (_) => setState(() => _selectedSeason = number),
                  ),
                ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text(
            '${episodes.length} episode${episodes.length == 1 ? '' : 's'}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
      SliverList.builder(
        itemCount: episodes.length,
        itemBuilder: (context, index) => _EpisodeTile(episode: episodes[index]),
      ),
    ];
  }

  List<Widget> _castSlivers(List<CastMember> cast) {
    if (cast.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: MessageView(icon: Icons.people_outline_rounded, title: 'No cast information available'),
        ),
      ];
    }
    return [
      SliverList.builder(
        itemCount: cast.length,
        itemBuilder: (context, index) => _CastTile(member: cast[index]),
      ),
    ];
  }
}

class _DetailsAppBar extends StatelessWidget {
  const _DetailsAppBar({required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 380,
      backgroundColor: AppColors.background,
      actions: [WatchlistIconButton(show: show)],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 56, end: 56, bottom: 14),
        title: Text(
          show.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            ShowPoster(url: show.imageOriginal ?? show.imageMedium, borderRadius: 0),
            // Darkens the top (for the buttons) and fades into the page at the bottom.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent, AppColors.background],
                  stops: [0, 0.4, 1],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Years, seasons, rating, genres, summary and the watchlist button.
class _ShowInfo extends StatelessWidget {
  const _ShowInfo({required this.show, required this.seasonCount});

  final Show show;
  final int? seasonCount; // null while episodes are loading

  @override
  Widget build(BuildContext context) {
    const secondary = TextStyle(color: AppColors.textSecondary);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(show.yearRange, style: secondary),
              if (seasonCount != null && seasonCount! > 0)
                Text('$seasonCount Season${seasonCount == 1 ? '' : 's'}', style: secondary),
              if (show.rating != null) RatingBadge(rating: show.rating!),
            ],
          ),
          if (show.genres.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final genre in show.genres)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(genre, style: const TextStyle(fontSize: 13)),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text(
            show.summary ?? 'No summary available.',
            style: const TextStyle(height: 1.5, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          BlocSelector<WatchlistBloc, WatchlistState, bool>(
            selector: (state) => state.contains(show.id),
            builder: (context, isSaved) => SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: isSaved ? AppColors.surfaceLight : AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => context.read<WatchlistBloc>().add(WatchlistShowToggled(show)),
                icon: Icon(isSaved ? Icons.close_rounded : Icons.add_rounded),
                label: Text(isSaved ? 'Remove from Watchlist' : 'Add to Watchlist'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    final premiered = DateTime.tryParse(show.premiered ?? '');
    final schedule = show.scheduleDays.isEmpty
        ? 'N/A'
        : '${show.scheduleDays.join(', ')}${show.scheduleTime?.isNotEmpty == true ? ' at ${show.scheduleTime}' : ''}';

    final rows = [
      (Icons.radio_button_checked_rounded, 'Status', show.status ?? 'Unknown'),
      (Icons.live_tv_rounded, 'Network', show.network ?? 'N/A'),
      (
        Icons.event_rounded,
        'Premiered',
        premiered == null ? 'Unknown' : MaterialLocalizations.of(context).formatShortDate(premiered),
      ),
      (Icons.schedule_rounded, 'Schedule', schedule),
      (Icons.timer_outlined, 'Runtime', show.runtime == null ? 'N/A' : '${show.runtime} min'),
      (Icons.language_rounded, 'Language', show.language ?? 'N/A'),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                for (final (index, (icon, label, value)) in rows.indexed) ...[
                  if (index > 0) const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            value,
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({required this.episode});

  final Episode episode;

  @override
  Widget build(BuildContext context) {
    final airdate = DateTime.tryParse(episode.airdate ?? '');
    final details = [
      if (airdate != null) MaterialLocalizations.of(context).formatShortDate(airdate),
      if (episode.runtime != null) '${episode.runtime} min',
    ].join('  •  ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Stack(
            children: [
              ShowPoster(
                url: episode.image,
                width: 120,
                height: 68,
                borderRadius: 8,
                placeholderIcon: Icons.movie_outlined,
              ),
              if (episode.number != null)
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'E${episode.number}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(details, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CastTile extends StatelessWidget {
  const _CastTile({required this.member});

  final CastMember member;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ShowPoster(
            url: member.image,
            width: 56,
            height: 56,
            borderRadius: 28,
            placeholderIcon: Icons.person_rounded,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(member.character, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps the TabBar pinned under the app bar while scrolling.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(color: AppColors.background, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => oldDelegate.tabBar != tabBar;
}
