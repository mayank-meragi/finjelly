import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/jellyfin_service.dart';
import 'auth_provider.dart';

final jellyfinServiceProvider = Provider<JellyfinService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return JellyfinService(authService);
});

final userViewsProvider = FutureProvider<List<dynamic>>((ref) async {
  final jellyfinService = ref.watch(jellyfinServiceProvider);
  return jellyfinService.getUserViews();
});

class LibraryItemsState {
  final List<dynamic> items;
  final bool isLoadingMore;
  final bool hasMore;

  LibraryItemsState({
    required this.items,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  LibraryItemsState copyWith({
    List<dynamic>? items,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return LibraryItemsState(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class LibraryItemsNotifier
    extends StateNotifier<AsyncValue<LibraryItemsState>> {
  final JellyfinService _jellyfinService;
  final String _parentId;
  static const int _limit = 25;

  LibraryItemsNotifier(this._jellyfinService, this._parentId)
    : super(const AsyncValue.loading()) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    try {
      final items = await _jellyfinService.getItems(
        _parentId,
        startIndex: 0,
        limit: _limit,
      );
      state = AsyncValue.data(
        LibraryItemsState(items: items, hasMore: items.length == _limit),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadNextPage() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    // Update state to show loading more
    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final currentItems = currentState.items;
      final newItems = await _jellyfinService.getItems(
        _parentId,
        startIndex: currentItems.length,
        limit: _limit,
      );

      state = AsyncValue.data(
        currentState.copyWith(
          items: [...currentItems, ...newItems],
          isLoadingMore: false,
          hasMore: newItems.length == _limit,
        ),
      );
    } catch (e, st) {
      // If loading next page fails, we probably want to keep the old data but show error?
      // For now, let's just set error state, or maybe just stop loading more.
      // A better UX would be to show a snackbar, but let's stick to simple error state.
      state = AsyncValue.error(e, st);
    }
  }
}

final libraryItemsProvider =
    StateNotifierProvider.family<
      LibraryItemsNotifier,
      AsyncValue<LibraryItemsState>,
      String
    >((ref, parentId) {
      final jellyfinService = ref.watch(jellyfinServiceProvider);
      return LibraryItemsNotifier(jellyfinService, parentId);
    });
