import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/library_provider.dart';
import '../utils/watch_status.dart';
import '../widgets/unwatched_badge.dart';
import 'video_player_screen.dart';
import 'season_screen.dart';

class DetailsScreen extends ConsumerWidget {
  final String itemId;
  final String itemName;

  const DetailsScreen({
    super.key,
    required this.itemId,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jellyfinService = ref.watch(jellyfinServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(itemName)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: jellyfinService.getItemDetails(itemId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No details found'));
          }

          final item = snapshot.data!;
          final overview = item['Overview'] ?? 'No description available.';
          final productionYear = item['ProductionYear']?.toString() ?? '';
          final communityRating = item['CommunityRating']?.toString() ?? '';
          final officialRating = item['OfficialRating'] ?? '';
          final resumePosition = getResumePosition(item);
          final remainingDuration = getRemainingDuration(item);
          final isMovie = item['Type'] == 'Movie';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Poster Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: SizedBox(
                        width: 300,
                        height: 450,
                        child: FutureBuilder<String>(
                          future: jellyfinService.getImageUrl(itemId),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.network(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.movie, size: 100),
                                    ),
                              );
                            }
                            return Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Details Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemName,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (productionYear.isNotEmpty)
                                Text(
                                  productionYear,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              if (officialRating.isNotEmpty) ...[
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    officialRating,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                              if (communityRating.isNotEmpty) ...[
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  communityRating,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Action Buttons
                          Row(
                            children: [
                              if (item['Type'] != 'Series')
                                FilledButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoPlayerScreen(
                                          itemId: itemId,
                                          itemName: itemName,
                                          initialPosition: resumePosition,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.black,
                                  ),
                                  label: Text(
                                    resumePosition != null ? 'Resume' : 'Play',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 16),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.bookmark_border),
                                tooltip: 'Add to List',
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.favorite_border),
                                tooltip: 'Mark as Favorite',
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.check),
                                tooltip: 'Mark as Played',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (isMovie && remainingDuration != null) ...[
                            Text(
                              '${formatDurationShort(remainingDuration)} remaining',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.amber),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            overview,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                // Seasons Section
                if (item['Type'] == 'Series') ...[
                  Text(
                    'Seasons',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<dynamic>>(
                    future: jellyfinService.getSeasons(itemId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final seasons = snapshot.data!;
                        return SizedBox(
                          height: 250,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: seasons.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final season =
                                  seasons[index] as Map<String, dynamic>;
                              final unwatchedCount = getUnwatchedEpisodeCount(
                                season,
                              );
                              return SizedBox(
                                width: 160,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SeasonScreen(
                                                      seriesId: itemId,
                                                      seasonId: season['Id'],
                                                      seasonName:
                                                          season['Name'],
                                                    ),
                                              ),
                                            );
                                          },
                                          child: FutureBuilder<String>(
                                            future: jellyfinService.getImageUrl(
                                              season['Id'],
                                            ),
                                            builder: (context, snapshot) {
                                              Widget poster;
                                              if (snapshot.hasData) {
                                                poster = Image.network(
                                                  snapshot.data!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => const Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                        ),
                                                      ),
                                                );
                                              } else {
                                                poster = const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }

                                              return Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  poster,
                                                  if (unwatchedCount != null)
                                                    UnwatchedBadge(
                                                      count: unwatchedCount,
                                                    ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      season['Name'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
