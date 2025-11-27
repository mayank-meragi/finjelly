bool isVideoWatched(Map<String, dynamic>? item) {
  if (item == null) {
    return false;
  }

  final mediaType = item['MediaType'] as String?;
  final type = item['Type'] as String?;
  final isVideo = mediaType == 'Video' ||
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
  if (playedPercentage is num && playedPercentage >= 90) {
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
