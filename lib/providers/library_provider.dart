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
  final bool? filterPlayedStatus; // null: all, true: played, false: unplayed
  final bool filterFavorites;
  final List<String> selectedGenreIds;
  final List<String> selectedOfficialRatings;
  final List<String> selectedYears;
  final Map<String, List<dynamic>> availableFilters;

  LibraryItemsState({
    required this.items,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.sortBy = 'SortName',
    this.sortOrder = 'Ascending',
    this.filterPlayedStatus,
    this.filterFavorites = false,
    this.selectedGenreIds = const [],
    this.selectedOfficialRatings = const [],
    this.selectedYears = const [],
    this.availableFilters = const {
      'Genres': [],
      'Years': [],
      'OfficialRatings': [],
    },
  });

  LibraryItemsState copyWith({
    List<dynamic>? items,
    bool? isLoadingMore,
    bool? hasMore,
    String? sortBy,
    String? sortOrder,
    bool? filterPlayedStatus,
    bool? filterFavorites,
    List<String>? selectedGenreIds,
    List<String>? selectedOfficialRatings,
    List<String>? selectedYears,
    Map<String, List<dynamic>>? availableFilters,
  }) {
    return LibraryItemsState(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      filterPlayedStatus: filterPlayedStatus ?? this.filterPlayedStatus,
      filterFavorites: filterFavorites ?? this.filterFavorites,
      selectedGenreIds: selectedGenreIds ?? this.selectedGenreIds,
      selectedOfficialRatings:
          selectedOfficialRatings ?? this.selectedOfficialRatings,
      selectedYears: selectedYears ?? this.selectedYears,
      availableFilters: availableFilters ?? this.availableFilters,
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
    final sortBy = prefs.getString('$_sortKeyPrefix${_parentId}_by');
    final sortOrder = prefs.getString('$_sortKeyPrefix${_parentId}_order');
    await _loadInitial(sortBy: sortBy, sortOrder: sortOrder);
  }

  Future<void> _saveSortOptions(String sortBy, String sortOrder) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_sortKeyPrefix${_parentId}_by', sortBy);
    await prefs.setString('$_sortKeyPrefix${_parentId}_order', sortOrder);
  }

  Future<void> _loadInitial({
    String? sortBy,
    String? sortOrder,
    bool? isPlayed,
    bool? isFavorite,
    List<String>? genreIds,
    List<String>? officialRatings,
    List<String>? years,
  }) async {
    try {
      final filters = await _jellyfinService.getFilters(_parentId);

      final items = await _jellyfinService.getItems(
        _parentId,
        startIndex: 0,
        limit: _limit,
        sortBy: sortBy ?? 'SortName',
        sortOrder: sortOrder ?? 'Ascending',
        isPlayed: isPlayed,
        isFavorite: isFavorite ?? false,
        genreIds: genreIds,
        officialRatings: officialRatings,
        years: years,
      );
      state = AsyncValue.data(
        LibraryItemsState(
          items: items,
          hasMore: items.length == _limit,
          sortBy: sortBy ?? 'SortName',
          sortOrder: sortOrder ?? 'Ascending',
          filterPlayedStatus: isPlayed,
          filterFavorites: isFavorite ?? false,
          selectedGenreIds: genreIds ?? [],
          selectedOfficialRatings: officialRatings ?? [],
          selectedYears: years ?? [],
          availableFilters: filters,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateFilters({
    bool? isPlayed,
    bool? isFavorite,
    List<String>? genreIds,
    List<String>? officialRatings,
    List<String>? years,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = const AsyncValue.loading();

    await _loadInitial(
      sortBy: currentState.sortBy,
      sortOrder: currentState.sortOrder,
      isPlayed: isPlayed ?? currentState.filterPlayedStatus,
      isFavorite: isFavorite ?? currentState.filterFavorites,
      genreIds: genreIds ?? currentState.selectedGenreIds,
      officialRatings: officialRatings ?? currentState.selectedOfficialRatings,
      years: years ?? currentState.selectedYears,
    );
  }

  Future<void> setSortOptions(String sortBy, String sortOrder) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Set loading state
    state = const AsyncValue.loading();

    await _saveSortOptions(sortBy, sortOrder);
    // Reload with new sort options
    await _loadInitial(
      sortBy: sortBy,
      sortOrder: sortOrder,
      isPlayed: currentState.filterPlayedStatus,
      isFavorite: currentState.filterFavorites,
      genreIds: currentState.selectedGenreIds,
      officialRatings: currentState.selectedOfficialRatings,
      years: currentState.selectedYears,
    );
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
        isPlayed: currentState.filterPlayedStatus,
        isFavorite: currentState.filterFavorites,
        genreIds: currentState.selectedGenreIds,
        officialRatings: currentState.selectedOfficialRatings,
        years: currentState.selectedYears,
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
