import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/library_provider.dart';
import '../utils/watch_status.dart';
import '../widgets/watched_indicator.dart';
import 'details_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  final String libraryId;
  final String libraryName;

  const LibraryScreen({
    super.key,
    required this.libraryId,
    required this.libraryName,
  });

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final ScrollController _scrollController = ScrollController();

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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(libraryItemsProvider(widget.libraryId).notifier).loadNextPage();
    }
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'SortName':
        return 'Name';
      case 'PremiereDate':
        return 'Release Date';
      case 'DateCreated':
        return 'Date Added';
      case 'CommunityRating':
        return 'Rating';
      case 'Random':
        return 'Random';
      default:
        return sortBy;
    }
  }

  String? _getSortValue(Map<String, dynamic> item, String sortBy) {
    switch (sortBy) {
      case 'PremiereDate':
        final date = item['PremiereDate'];
        if (date != null) {
          try {
            final dateTime = DateTime.parse(date);
            return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
          } catch (e) {
            return null;
          }
        }
        return null;
      case 'DateCreated':
        final date = item['DateCreated'];
        if (date != null) {
          try {
            final dateTime = DateTime.parse(date);
            return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
          } catch (e) {
            return null;
          }
        }
        return null;
      case 'CommunityRating':
        final rating = item['CommunityRating'];
        if (rating != null) {
          return '⭐ ${rating.toStringAsFixed(1)}';
        }
        return null;
      case 'SortName':
      case 'Random':
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsStateAsync = ref.watch(libraryItemsProvider(widget.libraryId));
    final jellyfinService = ref.watch(jellyfinServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.libraryName),
        actions: [
          itemsStateAsync.maybeWhen(
            data: (state) => Row(
              children: [
                // Sort field selector
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  tooltip: 'Sort by ${_getSortLabel(state.sortBy)}',
                  onSelected: (value) {
                    ref
                        .read(libraryItemsProvider(widget.libraryId).notifier)
                        .setSortOptions(value, state.sortOrder);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'SortName',
                      child: Row(
                        children: [
                          if (state.sortBy == 'SortName')
                            const Icon(Icons.check, size: 16)
                          else
                            const SizedBox(width: 16),
                          const SizedBox(width: 8),
                          const Text('Name'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'PremiereDate',
                      child: Row(
                        children: [
                          if (state.sortBy == 'PremiereDate')
                            const Icon(Icons.check, size: 16)
                          else
                            const SizedBox(width: 16),
                          const SizedBox(width: 8),
                          const Text('Release Date'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'DateCreated',
                      child: Row(
                        children: [
                          if (state.sortBy == 'DateCreated')
                            const Icon(Icons.check, size: 16)
                          else
                            const SizedBox(width: 16),
                          const SizedBox(width: 8),
                          const Text('Date Added'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'CommunityRating',
                      child: Row(
                        children: [
                          if (state.sortBy == 'CommunityRating')
                            const Icon(Icons.check, size: 16)
                          else
                            const SizedBox(width: 16),
                          const SizedBox(width: 8),
                          const Text('Rating'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'Random',
                      child: Row(
                        children: [
                          if (state.sortBy == 'Random')
                            const Icon(Icons.check, size: 16)
                          else
                            const SizedBox(width: 16),
                          const SizedBox(width: 8),
                          const Text('Random'),
                        ],
                      ),
                    ),
                  ],
                ),
                // Sort order toggle
                if (state.sortBy != 'Random')
                  IconButton(
                    icon: Icon(
                      state.sortOrder == 'Ascending'
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                    ),
                    tooltip: state.sortOrder == 'Ascending'
                        ? 'Ascending'
                        : 'Descending',
                    onPressed: () {
                      final newOrder = state.sortOrder == 'Ascending'
                          ? 'Descending'
                          : 'Ascending';
                      ref
                          .read(libraryItemsProvider(widget.libraryId).notifier)
                          .setSortOptions(state.sortBy, newOrder);
                    },
                  ),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: itemsStateAsync.when(
        data: (state) {
          final items = state.items;
          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: items.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final item = items[index] as Map<String, dynamic>;
                    final isWatched = isVideoWatched(item);
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                itemId: item['Id'],
                                itemName: item['Name'],
                              ),
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
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Center(
                                                child: Icon(Icons.broken_image),
                                              ),
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
                                      if (isWatched) const WatchedIndicator(),
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  if (_getSortValue(item, state.sortBy) !=
                                      null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _getSortValue(item, state.sortBy)!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
