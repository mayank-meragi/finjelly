import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';
import '../providers/library_provider.dart';
import '../providers/metadata_provider.dart';
import '../services/jellyfin_service.dart';
import '../utils/watch_status.dart';
import '../widgets/unwatched_badge.dart';
import '../widgets/watched_indicator.dart';
import '../widgets/metadata_badge.dart';
import 'details_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus search bar when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Simple debouncing - search after user stops typing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == query) {
        ref.read(searchProvider.notifier).search(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final jellyfinService = ref.watch(jellyfinServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          decoration: const InputDecoration(
            hintText: 'Search for movies, shows...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white60),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          onChanged: _onSearchChanged,
          onSubmitted: (query) {
            ref.read(searchProvider.notifier).search(query);
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(searchProvider.notifier).clear();
                _searchFocus.requestFocus();
              },
            ),
        ],
      ),
      body: _buildBody(searchState, jellyfinService),
    );
  }

  Widget _buildBody(SearchState searchState, JellyfinService jellyfinService) {
    if (searchState.query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Search for your favorite content',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${searchState.error}'),
          ],
        ),
      );
    }

    if (searchState.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No results found for "${searchState.query}"',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final item = searchState.results[index] as Map<String, dynamic>;
        final isWatched = isVideoWatched(item);
        final unwatchedCount = getUnwatchedEpisodeCount(item);
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetailsScreen(itemId: item['Id'], itemName: item['Name']),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: FutureBuilder<String>(
                    future: jellyfinService.getImageUrl(item['Id']),
                    builder: (context, snapshot) {
                      Widget child;
                      if (snapshot.hasData) {
                        child = Image.network(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.broken_image)),
                        );
                      } else {
                        child = const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          child,
                          if (unwatchedCount != null)
                            UnwatchedBadge(count: unwatchedCount),
                          if (isWatched) const WatchedIndicator(),
                          FutureBuilder<bool>(
                            future: ref
                                .read(appDatabaseProvider)
                                .hasMetadata(item['Id']),
                            builder: (context, snapshot) {
                              if (snapshot.data == true) {
                                return const MetadataBadge();
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['Name'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (item['ProductionYear'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${item['ProductionYear']}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
