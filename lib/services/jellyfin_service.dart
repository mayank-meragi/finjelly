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
  }) async {
    final serverUrl = await _authService.getServerUrl();
    final userId = await _authService.getUserId();
    final headers = await _getHeaders();

    try {
      final response = await _dio.get(
        '$serverUrl/Users/$userId/Items',
        queryParameters: {
          'ParentId': parentId,
          'SortBy': 'SortName',
          'SortOrder': 'Ascending',
          'Fields': 'PrimaryImageAspectRatio,Overview,ProductionYear',
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
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      print('Error fetching item details: $e');
      rethrow;
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
          'Fields': 'PrimaryImageAspectRatio,Overview,ProductionYear',
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
