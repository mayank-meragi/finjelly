import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/library_provider.dart';
import '../services/jellyfin_service.dart';
import '../utils/watch_status.dart';
import '../widgets/unwatched_badge.dart';
import '../widgets/watched_indicator.dart';
import 'details_screen.dart';
import 'library_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userViewsAsync = ref.watch(userViewsProvider);
    final jellyfinService = ref.watch(jellyfinServiceProvider);

    return userViewsAsync.when(
      data: (views) => ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: views.length,
        itemBuilder: (context, index) {
          final view = views[index];
          return _LibrarySection(
            libraryId: view['Id'],
            libraryName: view['Name'],
            jellyfinService: jellyfinService,
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _LibrarySection extends StatelessWidget {
  final String libraryId;
  final String libraryName;
  final JellyfinService jellyfinService;

  const _LibrarySection({
    required this.libraryId,
    required this.libraryName,
    required this.jellyfinService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                libraryName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LibraryScreen(
                        libraryId: libraryId,
                        libraryName: libraryName,
                      ),
                    ),
                  );
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        FutureBuilder<List<dynamic>>(
          future: jellyfinService.getRecentlyAdded(libraryId, limit: 10),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading items: ${snapshot.error}'),
              );
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No items'),
              );
            }

            return SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index] as Map<String, dynamic>;
                  final isWatched = isVideoWatched(item);
                  final unwatchedCount = getUnwatchedEpisodeCount(item);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      width: 160,
                      child: Card(
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
                                  future: jellyfinService.getImageUrl(
                                    item['Id'],
                                  ),
                                  builder: (context, imageSnapshot) {
                                    Widget child;
                                    if (imageSnapshot.hasData) {
                                      child = Image.network(
                                        imageSnapshot.data!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                  ),
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
                                        if (isWatched)
                                          const WatchedIndicator(),
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
                                    if (item['ProductionYear'] != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item['ProductionYear']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
