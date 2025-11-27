Duration? _durationFromTicks(dynamic ticks) {
  if (ticks is num) {
    return Duration(microseconds: ticks.toInt() ~/ 10);
  }
  return null;
}

bool isVideoWatched(Map<String, dynamic>? item) {
  if (item == null) {
    return false;
  }

  final mediaType = item['MediaType'] as String?;
  final type = item['Type'] as String?;
  final isVideo =
      mediaType == 'Video' ||
      type == 'Episode' ||
      type == 'Movie' ||
      type == 'Video';

  if (!isVideo) {
    return false;
  }

  final userData = item['UserData'];
  if (userData is! Map<String, dynamic>) {
    return false;
  }

  final played = userData['Played'];
  if (played is bool && played) {
    return true;
  }

  final playCount = userData['PlayCount'];
  if (playCount is num && playCount > 0) {
    return true;
  }

  final playedPercentage = userData['PlayedPercentage'];
  if (playedPercentage is num && playedPercentage >= 97) {
    return true;
  }

  return false;
}

int? getUnwatchedEpisodeCount(Map<String, dynamic>? item) {
  if (item == null) {
    return null;
  }

  final type = item['Type'] as String?;
  if (type != 'Series' && type != 'Season') {
    return null;
  }

  final userData = item['UserData'];
  if (userData is! Map<String, dynamic>) {
    return null;
  }

  final unplayed = userData['UnplayedItemCount'];
  if (unplayed is num && unplayed > 0) {
    return unplayed.toInt();
  }

  return null;
}

Duration? getResumePosition(Map<String, dynamic>? item) {
  if (item == null) {
    return null;
  }

  final userData = item['UserData'];
  if (userData is! Map<String, dynamic>) {
    return null;
  }

  final playbackTicks = userData['PlaybackPositionTicks'];
  final position = _durationFromTicks(playbackTicks);
  if (position == null || position <= Duration.zero) {
    return null;
  }

  final runtime = _durationFromTicks(item['RunTimeTicks']);
  if (runtime != null && position >= runtime) {
    return null;
  }

  return position;
}

Duration? getRemainingDuration(Map<String, dynamic>? item) {
  final runtime = _durationFromTicks(item?['RunTimeTicks']);
  final position = getResumePosition(item);

  if (runtime == null || position == null) {
    return null;
  }

  final remaining = runtime - position;
  if (remaining <= Duration.zero) {
    return null;
  }

  return remaining;
}

String formatDurationShort(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    if (minutes > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${hours}h';
  }

  if (minutes > 0) {
    if (seconds > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${minutes}m';
  }

  return '${seconds}s';
}
