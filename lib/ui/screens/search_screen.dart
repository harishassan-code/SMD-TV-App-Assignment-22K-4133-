import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/search/search_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/message_view.dart';
import '../widgets/show_list_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.focusNode});

  final FocusNode? focusNode;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Every keystroke goes to the BLoC; the BLoC debounces them.
  void _onChanged(String query) {
    setState(() {}); // show/hide the clear button
    context.read<SearchBloc>().add(SearchQueryChanged(query));
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              focusNode: widget.focusNode,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search TV shows...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.cancel_rounded),
                        onPressed: _clear,
                      ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) => switch (state) {
                SearchInitial() => const MessageView(
                    icon: Icons.manage_search_rounded,
                    title: 'Find your favorite shows',
                    message: 'Start typing a show name to search.',
                  ),
                SearchLoading() => const Center(child: CircularProgressIndicator()),
                SearchEmpty(:final query) => MessageView(
                    icon: Icons.search_off_rounded,
                    title: 'No results found',
                    message: 'No shows match "$query". Try a different name.',
                  ),
                SearchFailure(:final message) => MessageView(
                    icon: Icons.error_outline_rounded,
                    title: 'Something went wrong',
                    message: message,
                    actionLabel: 'Retry',
                    onAction: () => context.read<SearchBloc>().add(SearchQueryChanged(_controller.text)),
                  ),
                SearchSuccess(:final shows) => ListView.separated(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: shows.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, indent: 94),
                    itemBuilder: (context, index) => ShowListTile(
                      show: shows[index],
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    ),
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
