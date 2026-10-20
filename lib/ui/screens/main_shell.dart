import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/watchlist/watchlist_bloc.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'watchlist_screen.dart';

/// The bottom navigation bar and its three tabs.
/// IndexedStack keeps every tab alive, so scroll position and
/// search text are not lost when switching tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _searchFocus = FocusNode();

  void _selectTab(int index) => setState(() => _index = index);

  void _openSearch() {
    _selectTab(1);
    // Focus after the frame, once the Search tab is visible.
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocus.requestFocus());
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onSearchTap: _openSearch),
          SearchScreen(focusNode: _searchFocus),
          WatchlistScreen(onExplore: () => _selectTab(0)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _selectTab,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: BlocSelector<WatchlistBloc, WatchlistState, int>(
              selector: (state) => state.shows.length,
              builder: (context, count) => Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: Icon(_index == 2 ? Icons.favorite_rounded : Icons.favorite_border_rounded),
              ),
            ),
            label: 'Watchlist',
          ),
        ],
      ),
    );
  }
}
