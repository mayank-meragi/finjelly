import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/library_provider.dart';
import '../utils/watch_status.dart';
import '../widgets/watched_indicator.dart';
import 'video_player_screen.dart';

class SeasonScreen extends ConsumerWidget {
  final String seriesId;
  final String seasonId;
  final String seasonName;

  const SeasonScreen({
    super.key,
    required this.seriesId,
    required this.seasonId,
    required this.seasonName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jellyfinService = ref.watch(jellyfinServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(seasonName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Season Details
            FutureBuilder<Map<String, dynamic>>(
              future: jellyfinService.getItemDetails(seasonId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final season = snapshot.data!;
                  final overview =
                      season['Overview'] ?? 'No description available.';
                  final productionYear =
                      season['ProductionYear']?.toString() ?? '';
                  final seriesName = season['SeriesName'] ?? 'Unknown Series';

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Season Poster
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: SizedBox(
                          width: 300,
                          height: 450,
                          child: FutureBuilder<String>(
                            future: jellyfinService.getImageUrl(seasonId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.network(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: Colors.grey[800],
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 100,
                                        ),
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
                      // Season Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              seriesName,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              seasonName,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            if (productionYear.isNotEmpty)
                              Text(
                                productionYear,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            const SizedBox(height: 24),
                            // Actions (Visual only for now)
                            Row(
                              children: [
                                FilledButton.icon(
                                  onPressed: () {
                                    // TODO: Play first episode
                                  },
                                  icon: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.black,
                                  ),
                                  label: const Text(
                                    'Play',
                                    style: TextStyle(color: Colors.black),
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
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.check),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              overview,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox(
                  height: 450,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
            const SizedBox(height: 48),
            // Bottom Section: Episodes Grid
            FutureBuilder<List<dynamic>>(
              future: jellyfinService.getEpisodes(seriesId, seasonId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final episodes = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${episodes.length} Episodes',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, // Adjust based on screen width
                              childAspectRatio: 16 / 12, // 16:9 image + text
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 24,
                            ),
                        itemCount: episodes.length,
                        itemBuilder: (context, index) {
                          final episode =
                              episodes[index] as Map<String, dynamic>;
                          final isWatched = isVideoWatched(episode);
                          final episodeIndex =
                              episode['IndexNumber'] ?? index + 1;
                          return Column(
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
                                              VideoPlayerScreen(
                                                itemId: episode['Id'],
                                                itemName: episode['Name'],
                                              ),
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        FutureBuilder<String>(
                                          future: jellyfinService.getImageUrl(
                                            episode['Id'],
                                            type: 'Primary',
                                          ),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Image.network(
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
                                            }
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                        ),
                                        Center(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.5,
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            child: const Icon(
                                              Icons.play_arrow,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        if (isWatched) const WatchedIndicator(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                episode['Name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Episode $episodeIndex',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }
}
