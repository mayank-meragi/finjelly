import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/jellyfin_service.dart';
import 'library_provider.dart';

class SearchState {
  final String query;
  final List<dynamic> results;
  final bool isLoading;
  final String? error;

  SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<dynamic>? results,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final JellyfinService _jellyfinService;

  SearchNotifier(this._jellyfinService) : super(SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = SearchState();
      return;
    }

    state = state.copyWith(query: query, isLoading: true);

    try {
      final results = await _jellyfinService.searchItems(query);
      state = state.copyWith(results: results, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    state = SearchState();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  final jellyfinService = ref.watch(jellyfinServiceProvider);
  return SearchNotifier(jellyfinService);
});
