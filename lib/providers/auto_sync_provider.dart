import 'package:flutter_riverpod/flutter_riverpod.dart';

class AutoSyncTracker extends StateNotifier<Set<String>> {
  AutoSyncTracker() : super(<String>{});

  bool hasBeenSynced(String libraryId) {
    return state.contains(libraryId);
  }

  void markAsSynced(String libraryId) {
    state = {...state, libraryId};
  }

  void reset() {
    state = <String>{};
  }
}

final autoSyncTrackerProvider =
    StateNotifierProvider<AutoSyncTracker, Set<String>>(
      (ref) => AutoSyncTracker(),
    );
