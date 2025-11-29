import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/library_provider.dart';
import '../providers/metadata_provider.dart';
import '../providers/sync_state_provider.dart';
import '../providers/auto_sync_provider.dart';
import '../utils/watch_status.dart';
import '../widgets/unwatched_badge.dart';
import '../widgets/watched_indicator.dart';
import '../widgets/metadata_badge.dart';
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
    _triggerAutoSync();
  }

  Future<void> _triggerAutoSync() async {
    final prefs = await SharedPreferences.getInstance();
    final autoSyncEnabled = prefs.getBool('auto_sync_metadata') ?? true;

    if (!autoSyncEnabled) return;

    final syncTracker = ref.read(autoSyncTrackerProvider.notifier);
    final hasBeenSynced = syncTracker.hasBeenSynced(widget.libraryId);

    if (hasBeenSynced) {
      return; // Already synced this session
    }

    final metadataSync = ref.read(metadataSyncServiceProvider);
    final syncState = ref.read(syncStateProvider.notifier);

    // Mark as synced before starting to prevent duplicate syncs
    syncTracker.markAsSynced(widget.libraryId);

    // Show subtle initial toast
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auto-syncing metadata...'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.blue,
        ),
      );
    }

    // Start background sync
    syncState.startSync(0);

    metadataSync
        .syncUnsyncedItems(
          widget.libraryId,
          onProgress: (done, total) {
            syncState.updateProgress(done, total);

            // Show progress toast every 10 items or at the end
            if (done % 10 == 0 || done == total) {
              if (mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                if (total > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Auto-sync: $done/$total'),
                      duration: done == total
                          ? const Duration(seconds: 3)
                          : const Duration(seconds: 1),
                      backgroundColor: done == total
                          ? Colors.green
                          : Colors.blue,
                    ),
                  );
                }
              }
            }
          },
        )
        .then((_) {
          syncState.endSync();
        })
        .catchError((e) {
          syncState.endSync();
        });
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

  void _showFilterDialog(BuildContext context, LibraryItemsState currentState) {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        initialState: currentState,
        onApply:
            (
              bool? isPlayed,
              bool isFavorite,
              List<String> genreIds,
              List<String> officialRatings,
              List<String> years,
            ) {
              ref
                  .read(libraryItemsProvider(widget.libraryId).notifier)
                  .updateFilters(
                    isPlayed: isPlayed,
                    isFavorite: isFavorite,
                    genreIds: genreIds,
                    officialRatings: officialRatings,
                    years: years,
                  );
            },
      ),
    );
  }

  Future<void> _syncMetadata(BuildContext context) async {
    final metadataSync = ref.read(metadataSyncServiceProvider);
    final syncState = ref.read(syncStateProvider.notifier);

    // Start sync in background
    syncState.startSync(0);

    // Show initial toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Starting metadata sync...'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );

    // Run sync in background
    metadataSync
        .syncLibrary(
          widget.libraryId,
          onProgress: (done, total) {
            syncState.updateProgress(done, total);

            // Show progress toast every 5 items or at the end
            if (done % 5 == 0 || done == total) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Syncing metadata: $done/$total'),
                    duration: done == total
                        ? const Duration(seconds: 3)
                        : const Duration(seconds: 1),
                    backgroundColor: done == total ? Colors.green : Colors.blue,
                  ),
                );
              }
            }
          },
        )
        .then((_) {
          syncState.endSync();
        })
        .catchError((e) {
          syncState.endSync();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sync failed: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
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
                // Sync Metadata button
                IconButton(
                  icon: const Icon(Icons.sync),
                  tooltip: 'Sync Metadata',
                  onPressed: () => _syncMetadata(context),
                ),
                // Filter button
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filter',
                  onPressed: () => _showFilterDialog(context, state),
                ),
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
                    final unwatchedCount = getUnwatchedEpisodeCount(item);
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

class _FilterDialog extends StatefulWidget {
  final LibraryItemsState initialState;
  final Function(
    bool? isPlayed,
    bool isFavorite,
    List<String> genreIds,
    List<String> officialRatings,
    List<String> years,
  )
  onApply;

  const _FilterDialog({required this.initialState, required this.onApply});

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late bool? _isPlayed;
  late bool _isFavorite;
  late List<String> _selectedGenreIds;
  late List<String> _selectedOfficialRatings;
  late List<String> _selectedYears;

  @override
  void initState() {
    super.initState();
    _isPlayed = widget.initialState.filterPlayedStatus;
    _isFavorite = widget.initialState.filterFavorites;
    _selectedGenreIds = List.from(widget.initialState.selectedGenreIds);
    _selectedOfficialRatings = List.from(
      widget.initialState.selectedOfficialRatings,
    );
    _selectedYears = List.from(widget.initialState.selectedYears);
  }

  @override
  Widget build(BuildContext context) {
    final genres = widget.initialState.availableFilters['Genres'] ?? [];
    final years = widget.initialState.availableFilters['Years'] ?? [];
    final officialRatings =
        widget.initialState.availableFilters['OfficialRatings'] ?? [];

    return AlertDialog(
      title: const Text('Filter Library'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _isPlayed == null,
                  onSelected: (selected) {
                    if (selected) setState(() => _isPlayed = null);
                  },
                ),
                FilterChip(
                  label: const Text('Played'),
                  selected: _isPlayed == true,
                  onSelected: (selected) {
                    if (selected) setState(() => _isPlayed = true);
                  },
                ),
                FilterChip(
                  label: const Text('Unplayed'),
                  selected: _isPlayed == false,
                  onSelected: (selected) {
                    if (selected) setState(() => _isPlayed = false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Favorites Only',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Switch(
                  value: _isFavorite,
                  onChanged: (value) => setState(() => _isFavorite = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (genres.isNotEmpty) ...[
              const Text(
                'Genres',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genres.map<Widget>((genre) {
                  final genreId = genre['Id'] as String;
                  final genreName = genre['Name'] as String;
                  return FilterChip(
                    label: Text(genreName),
                    selected: _selectedGenreIds.contains(genreId),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedGenreIds.add(genreId);
                        } else {
                          _selectedGenreIds.remove(genreId);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (years.isNotEmpty) ...[
              const Text(
                'Years',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: years.map<Widget>((year) {
                  final yearStr = year.toString();
                  return FilterChip(
                    label: Text(yearStr),
                    selected: _selectedYears.contains(yearStr),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedYears.add(yearStr);
                        } else {
                          _selectedYears.remove(yearStr);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (officialRatings.isNotEmpty) ...[
              const Text(
                'Official Ratings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: officialRatings.map<Widget>((rating) {
                  final ratingName = rating as String;
                  return FilterChip(
                    label: Text(ratingName),
                    selected: _selectedOfficialRatings.contains(ratingName),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedOfficialRatings.add(ratingName);
                        } else {
                          _selectedOfficialRatings.remove(ratingName);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onApply(
              _isPlayed,
              _isFavorite,
              _selectedGenreIds,
              _selectedOfficialRatings,
              _selectedYears,
            );
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
