import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorites_provider.dart';
import '../providers/library_provider.dart';
import '../utils/watch_status.dart';
import '../widgets/unwatched_badge.dart';
import '../widgets/watched_indicator.dart';
import 'details_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);
    final jellyfinService = ref.watch(jellyfinServiceProvider);

    return favoritesAsync.when(
      data: (favorites) {
        if (favorites.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No favorites yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
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
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final item = favorites[index] as Map<String, dynamic>;
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
                              errorBuilder: (context, error, stackTrace) =>
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
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
