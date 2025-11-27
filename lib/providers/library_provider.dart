import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final String sortBy;
  final String sortOrder;

  LibraryItemsState({
    required this.items,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.sortBy = 'SortName',
    this.sortOrder = 'Ascending',
  });

  LibraryItemsState copyWith({
    List<dynamic>? items,
    bool? isLoadingMore,
    bool? hasMore,
    String? sortBy,
    String? sortOrder,
  }) {
    return LibraryItemsState(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class LibraryItemsNotifier
    extends StateNotifier<AsyncValue<LibraryItemsState>> {
  final JellyfinService _jellyfinService;
  final String _parentId;
  static const int _limit = 25;
  static const String _sortKeyPrefix = 'library_sort_';

  LibraryItemsNotifier(this._jellyfinService, this._parentId)
    : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final sortBy = prefs.getString('${_sortKeyPrefix}${_parentId}_by');
    final sortOrder = prefs.getString('${_sortKeyPrefix}${_parentId}_order');
    await _loadInitial(sortBy: sortBy, sortOrder: sortOrder);
  }

  Future<void> _saveSortOptions(String sortBy, String sortOrder) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_sortKeyPrefix}${_parentId}_by', sortBy);
    await prefs.setString('${_sortKeyPrefix}${_parentId}_order', sortOrder);
  }

  Future<void> _loadInitial({String? sortBy, String? sortOrder}) async {
    try {
      final items = await _jellyfinService.getItems(
        _parentId,
        startIndex: 0,
        limit: _limit,
        sortBy: sortBy ?? 'SortName',
        sortOrder: sortOrder ?? 'Ascending',
      );
      state = AsyncValue.data(
        LibraryItemsState(
          items: items,
          hasMore: items.length == _limit,
          sortBy: sortBy ?? 'SortName',
          sortOrder: sortOrder ?? 'Ascending',
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setSortOptions(String sortBy, String sortOrder) async {
    // Set loading state
    state = const AsyncValue.loading();

    await _saveSortOptions(sortBy, sortOrder);
    // Reload with new sort options
    await _loadInitial(sortBy: sortBy, sortOrder: sortOrder);
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
        sortBy: currentState.sortBy,
        sortOrder: currentState.sortOrder,
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
