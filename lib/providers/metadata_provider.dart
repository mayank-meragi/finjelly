import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../services/tmdb_service.dart';
import '../services/metadata_sync_service.dart';
import 'library_provider.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final tmdbServiceProvider = Provider<TMDBService>((ref) {
  return TMDBService();
});

final metadataSyncServiceProvider = Provider<MetadataSyncService>((ref) {
  final jellyfinService = ref.watch(jellyfinServiceProvider);
  final tmdbService = ref.watch(tmdbServiceProvider);
  final db = ref.watch(appDatabaseProvider);
  return MetadataSyncService(jellyfinService, tmdbService, db);
});
