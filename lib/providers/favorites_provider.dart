import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'library_provider.dart';

final favoritesProvider = FutureProvider<List<dynamic>>((ref) async {
  final jellyfinService = ref.watch(jellyfinServiceProvider);
  return jellyfinService.getFavorites();
});
