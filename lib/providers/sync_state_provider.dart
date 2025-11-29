import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncState {
  final bool isSyncing;
  final int done;
  final int total;

  SyncState({this.isSyncing = false, this.done = 0, this.total = 0});

  SyncState copyWith({bool? isSyncing, int? done, int? total}) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      done: done ?? this.done,
      total: total ?? this.total,
    );
  }

  String get progressText => '$done/$total';
}

class SyncStateNotifier extends StateNotifier<SyncState> {
  SyncStateNotifier() : super(SyncState());

  void startSync(int total) {
    state = SyncState(isSyncing: true, done: 0, total: total);
  }

  void updateProgress(int done, int total) {
    state = state.copyWith(done: done, total: total);
  }

  void endSync() {
    state = SyncState(isSyncing: false, done: 0, total: 0);
  }
}

final syncStateProvider = StateNotifierProvider<SyncStateNotifier, SyncState>(
  (ref) => SyncStateNotifier(),
);
