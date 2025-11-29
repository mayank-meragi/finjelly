import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/database.dart';
import 'jellyfin_service.dart';
import 'tmdb_service.dart';

class MetadataSyncService {
  final JellyfinService _jellyfinService;
  final TMDBService _tmdbService;
  final AppDatabase _db;

  MetadataSyncService(this._jellyfinService, this._tmdbService, this._db);

  Future<void> syncLibrary(
    String parentId, {
    void Function(int done, int total)? onProgress,
  }) async {
    // Fetch all items from Jellyfin
    // We need to fetch recursively to get everything
    final items = await _jellyfinService.getItems(
      parentId,
      limit: 1000, // Fetch a large batch, or implement pagination
      // In a real app, we should paginate properly
    );

    final total = items.length;
    int done = 0;

    for (final item in items) {
      await _syncItem(item);
      done++;
      onProgress?.call(done, total);
    }
  }

  Future<void> syncUnsyncedItems(
    String parentId, {
    void Function(int done, int total)? onProgress,
  }) async {
    // Fetch all items from Jellyfin
    final items = await _jellyfinService.getItems(parentId, limit: 1000);

    // Filter to only unsynced items
    final unsyncedItems = <Map<String, dynamic>>[];
    for (final item in items) {
      final jellyfinId = item['Id'] as String;
      final hasMetadata = await _db.hasMetadata(jellyfinId);
      if (!hasMetadata) {
        unsyncedItems.add(item);
      }
    }

    final total = unsyncedItems.length;
    int done = 0;

    for (final item in unsyncedItems) {
      await _syncItem(item);
      done++;
      onProgress?.call(done, total);
    }
  }

  Future<void> _syncItem(Map<String, dynamic> item) async {
    final jellyfinId = item['Id'] as String;
    final name = item['Name'] as String;
    final type = item['Type'] as String;
    final productionYear = item['ProductionYear'] as int?;
    final providerIds = item['ProviderIds'] as Map<String, dynamic>?;

    // Skip if not a movie or series
    if (type != 'Movie' && type != 'Series') return;

    // Check if already exists and is fresh (e.g., updated < 7 days ago)
    final existing = await (_db.select(
      _db.videoMetadata,
    )..where((t) => t.jellyfinId.equals(jellyfinId))).getSingleOrNull();

    if (existing != null) {
      final difference = DateTime.now().difference(existing.lastUpdated);
      if (difference.inDays < 7) {
        return; // Data is fresh enough
      }
    }

    // Try to find TMDB ID
    int? tmdbId;
    if (providerIds != null && providerIds.containsKey('Tmdb')) {
      tmdbId = int.tryParse(providerIds['Tmdb'].toString());
    }

    Map<String, dynamic>? details;

    if (tmdbId != null) {
      if (type == 'Movie') {
        details = await _tmdbService.getMovieDetails(tmdbId);
      } else {
        details = await _tmdbService.getShowDetails(tmdbId);
      }
    } else {
      // Search by name if no ID
      if (type == 'Movie') {
        final searchResult = await _tmdbService.searchMovie(
          name,
          productionYear,
        );
        if (searchResult != null) {
          tmdbId = searchResult['id'];
          details = await _tmdbService.getMovieDetails(tmdbId!);
        }
      } else {
        final searchResult = await _tmdbService.searchShow(
          name,
          productionYear,
        );
        if (searchResult != null) {
          tmdbId = searchResult['id'];
          details = await _tmdbService.getShowDetails(tmdbId!);
        }
      }
    }

    if (details != null) {
      // Extract metadata
      final budget = details['budget'] as int? ?? 0;
      final revenue = details['revenue'] as int? ?? 0;

      // Extract director (from credits)
      String director = '';
      final credits = details['credits'] as Map<String, dynamic>?;
      if (credits != null) {
        final crew = credits['crew'] as List<dynamic>?;
        if (crew != null) {
          final directorEntry = crew.firstWhere(
            (m) => m['job'] == 'Director',
            orElse: () => null,
          );
          if (directorEntry != null) {
            director = directorEntry['name'];
          }
        }
      }

      // Extract cast
      List<String> castList = [];
      if (credits != null) {
        final cast = credits['cast'] as List<dynamic>?;
        if (cast != null) {
          castList = cast.take(5).map((c) => c['name'] as String).toList();
        }
      }

      // Save to DB
      await _db
          .into(_db.videoMetadata)
          .insertOnConflictUpdate(
            VideoMetadataCompanion(
              jellyfinId: Value(jellyfinId),
              tmdbId: Value(tmdbId),
              budget: Value(budget),
              revenue: Value(revenue),
              director: Value(director),
              cast: Value(jsonEncode(castList)),
              lastUpdated: Value(DateTime.now()),
            ),
          );
    }
  }
}
