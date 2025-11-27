import 'package:dio/dio.dart';

import 'auth_service.dart';

class JellyfinService {
  final AuthService _authService;
  final Dio _dio = Dio();

  JellyfinService(this._authService);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'X-Emby-Token': token ?? '',
      'X-Emby-Authorization':
          'MediaBrowser Client="FinJelly", Device="Flutter Desktop", DeviceId="finjelly-desktop", Version="1.0.0"',
    };
  }

  Future<List<dynamic>> getUserViews() async {
    final serverUrl = await _authService.getServerUrl();
    final userId = await _authService.getUserId();
    final headers = await _getHeaders();

    try {
      final response = await _dio.get(
        '$serverUrl/Users/$userId/Views',
        options: Options(headers: headers),
      );
      return response.data['Items'];
    } catch (e) {
      print('Error fetching user views: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getItems(
    String parentId, {
    int startIndex = 0,
    int limit = 25,
    String sortBy = 'SortName',
    String sortOrder = 'Ascending',
  }) async {
    final serverUrl = await _authService.getServerUrl();
    final userId = await _authService.getUserId();
    final headers = await _getHeaders();

    try {
      final response = await _dio.get(
        '$serverUrl/Users/$userId/Items',
        queryParameters: {
          'ParentId': parentId,
          'SortBy': sortBy,
          'SortOrder': sortOrder,
          'Fields':
              'PrimaryImageAspectRatio,Overview,ProductionYear,DateCreated,PremiereDate,CommunityRating,UserData',
          'StartIndex': startIndex,
          'Limit': limit,
        },
        options: Options(headers: headers),
      );
      return response.data['Items'];
    } catch (e) {
      print('Error fetching items: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> searchItems(String searchTerm) async {
    if (searchTerm.isEmpty) {
      return [];
    }

    final serverUrl = await _authService.getServerUrl();
    final userId = await _authService.getUserId();
    final headers = await _getHeaders();

    try {
      final response = await _dio.get(
        '$serverUrl/Users/$userId/Items',
        queryParameters: {
          'searchTerm': searchTerm,
          'Recursive': true,
          'Fields':
              'PrimaryImageAspectRatio,Overview,ProductionYear,DateCreated,PremiereDate,CommunityRating,UserData',
          'Limit': 50,
        },
        options: Options(headers: headers),
      );
      return response.data['Items'] ?? [];
    } catch (e) {
      print('Error searching items: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getRecentlyAdded(
    String parentId, {
    int limit = 10,
  }) async {
    final serverUrl = await _authService.getServerUrl();
    final userId = await _authService.getUserId();
    final headers = await _getHeaders();

    try {
      final response = await _dio.get(
        '$serverUrl/Users/$userId/Items',
        queryParameters: {
          'ParentId': parentId,
          'SortBy': 'DateCreated',
          'SortOrder': 'Descending',
          'Recursive': true,
          'Fields':
              'PrimaryImageAspectRatio,Overview,ProductionYear,DateCreated,PremiereDate,CommunityRating,UserData',
          'Limit': limit,
        },
        options: Options(headers: headers),
      );
      return response.data['Items'] ?? [];
    } catch (e) {
      print('Error fetching recently added: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite(String itemId, bool isFavorite) async {
    final serverUrl = await _authService.getServerUrl();
    final userId = await _authService.getUserId();
    final headers = await _getHeaders();

    try {
      if (isFavorite) {
        // Remove from favorites
        await _dio.delete(
          '$serverUrl/Users/$userId/FavoriteItems/$itemId',
          options: Options(headers: headers),
        );
      } else {
        // Add to favorites
        await _dio.post(
          '$serverUrl/Users/$userId/FavoriteItems/$itemId',
          options: Options(headers: headers),
        );
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getFavorites() async {
    final serverUrl = await _authService.getServerUrl();
    final userId = await _authService.getUserId();
    final headers = await _getHeaders();

    try {
      final response = await _dio.get(
        '$serverUrl/Users/$userId/Items',
        queryParameters: {
          'Filters': 'IsFavorite',
          'Recursive': true,
          'Fields':
              'PrimaryImageAspectRatio,Overview,ProductionYear,DateCreated,PremiereDate,CommunityRating,UserData',
        },
        options: Options(headers: headers),
      );
      return response.data['Items'] ?? [];
    } catch (e) {
      print('Error fetching favorites: $e');
      rethrow;
    }
  }

  Future<String> getImageUrl(String itemId, {String type = 'Primary'}) async {
    final serverUrl = await _authService.getServerUrl();
    return '$serverUrl/Items/$itemId/Images/$type';
  }

  Future<Map<String, dynamic>> getItemDetails(String itemId) async {
    final serverUrl = await _authService.getServerUrl();
    final userId = await _authService.getUserId();
    final headers = await _getHeaders();

    try {
      final response = await _dio.get(
        '$serverUrl/Users/$userId/Items/$itemId',
        queryParameters: {
          'Fields': 'UserData,RunTimeTicks',
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      print('Error fetching item details: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getChapters(String itemId) async {
    final headers = await _getHeaders();
    final userId = await _authService.getUserId();
    final serverUrl = await _authService.getServerUrl();
    try {
      final response = await _dio.get(
        '$serverUrl/Users/$userId/Items/$itemId',
        options: Options(headers: headers),
      );
      if (response.statusCode == 200) {
        return response.data['Chapters'] ?? [];
      } else {
        throw Exception('Failed to load chapters');
      }
    } catch (e) {
      // print('Error fetching chapters: $e');
      return [];
    }
  }

  Future<List<dynamic>> getSeasons(String seriesId) async {
    final serverUrl = await _authService.getServerUrl();
    final userId = await _authService.getUserId();
    final headers = await _getHeaders();

    try {
      final response = await _dio.get(
        '$serverUrl/Users/$userId/Items',
        queryParameters: {
          'ParentId': seriesId,
          'IncludeItemTypes': 'Season',
          'SortBy': 'SortName',
          'SortOrder': 'Ascending',
          'Fields': 'PrimaryImageAspectRatio,Overview,ProductionYear,UserData',
        },
        options: Options(headers: headers),
      );
      return response.data['Items'];
    } catch (e) {
      print('Error fetching seasons: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getEpisodes(String seriesId, String seasonId) async {
    final serverUrl = await _authService.getServerUrl();
    final userId = await _authService.getUserId();
    final headers = await _getHeaders();

    try {
      final response = await _dio.get(
        '$serverUrl/Users/$userId/Items',
        queryParameters: {
          'ParentId': seasonId,
          'IncludeItemTypes': 'Episode',
          'SortBy': 'SortName',
          'SortOrder': 'Ascending',
          'Fields':
              'PrimaryImageAspectRatio,Overview,ProductionYear,UserData,RunTimeTicks',
        },
        options: Options(headers: headers),
      );
      return response.data['Items'];
    } catch (e) {
      print('Error fetching episodes: $e');
      rethrow;
    }
  }

  Future<String> getPlaybackUrl(String itemId) async {
    final serverUrl = await _authService.getServerUrl();
    final token = await _authService.getToken();
    // Basic playback URL. Transcoding options would be added here in a full app.
    return '$serverUrl/Videos/$itemId/stream?static=true&api_key=$token';
  }
}
